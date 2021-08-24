terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}

resource "azurerm_resource_group" "tf_rg" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "tf_vnet" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_rg.name
  address_space       = [var.cidr]
  dns_servers         = ["${local.dns_server_ip}", "168.63.129.16"]
}

resource "azurerm_subnet" "tf_vnet_sn_dmz" {
  name                 = "${var.name}-vnet-sn-dmz"
  resource_group_name  = azurerm_resource_group.tf_rg.name
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = [local.cidr_dmz]
}

resource "azurerm_subnet" "tf_vnet_sn_priv" {
  name                 = "${var.name}-vnet-sn-priv"
  resource_group_name  = azurerm_resource_group.tf_rg.name
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = [local.cidr_priv]
}

resource "azurerm_route_table" "tf_rt_dmz" {
  name                = "${var.name}-rt-dmz"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_rg.name

  route {
    name           = "local"
    address_prefix = var.cidr
    next_hop_type  = "vnetlocal"
  }

  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_route_table" "tf_rt_priv" {
  name                = "${var.name}-rt-priv"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_rg.name

  route {
    name           = "local"
    address_prefix = var.cidr
    next_hop_type  = "vnetlocal"
  }

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.vce_ip_priv
  }
}

resource "azurerm_subnet_route_table_association" "tf_sn_rt_assoc_dmz" {
  subnet_id      = azurerm_subnet.tf_vnet_sn_dmz.id
  route_table_id = azurerm_route_table.tf_rt_dmz.id
}

resource "azurerm_subnet_route_table_association" "tf_sn_rt_assoc_priv" {
  subnet_id      = azurerm_subnet.tf_vnet_sn_priv.id
  route_table_id = azurerm_route_table.tf_rt_priv.id
}

resource "azurerm_public_ip" "tf_pub_vce_wan" {
  name                = "${var.name}-pub-vce-wan"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "tf_vce_wan_nsg" {
  name                = "${var.name}-vce-wan-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_rg.name
}

resource "azurerm_network_security_rule" "tf_vce_wan_nsg_rules" {
  for_each                    = local.wan_nsg_rules
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.tf_rg.name
  network_security_group_name = azurerm_network_security_group.tf_vce_wan_nsg.name
}

resource "azurerm_network_interface" "tf_nic_vce_ge1" {
  name                = "${var.name}-nic-vce-ge1"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_rg.name

  ip_configuration {
    name                          = "${var.name}-nic-vce-ge1-cfg"
    subnet_id                     = azurerm_subnet.tf_vnet_sn_dmz.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "tf_nic_vce_wan" {
  name                = "${var.name}-nic-vce-wan"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_rg.name

  ip_configuration {
    name                          = "${var.name}-nic-vce-wan-cfg"
    subnet_id                     = azurerm_subnet.tf_vnet_sn_dmz.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf_pub_vce_wan.id
  }
}

resource "azurerm_network_interface" "tf_nic_vce_lan" {
  name                 = "${var.name}-nic-vce-lan"
  location             = var.location
  resource_group_name  = azurerm_resource_group.tf_rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${var.name}-nic-vce-lan-cfg"
    subnet_id                     = azurerm_subnet.tf_vnet_sn_priv.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vce_ip_priv
  }
}

resource "azurerm_network_interface_security_group_association" "tf_nic_nsg_vce_wan" {
  network_interface_id      = azurerm_network_interface.tf_nic_vce_wan.id
  network_security_group_id = azurerm_network_security_group.tf_vce_wan_nsg.id
}

resource "azurerm_linux_virtual_machine" "tf_vm_vce" {
  name                            = "${var.name}-vm-vce"
  resource_group_name             = azurerm_resource_group.tf_rg.name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data                     = local.vce_userdata

  network_interface_ids = [
    azurerm_network_interface.tf_nic_vce_ge1.id,
    azurerm_network_interface.tf_nic_vce_wan.id,
    azurerm_network_interface.tf_nic_vce_lan.id
  ]

  plan {
    name      = "velocloud-virtual-edge-3x"
    product   = "velocloud-virtual-edge-3x"
    publisher = "velocloud"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_key
  }

  os_disk {
    caching              = "None"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "velocloud"
    offer     = "velocloud-virtual-edge-3x"
    sku       = "velocloud-virtual-edge-3x"
    version   = "3.0.0"
  }
}

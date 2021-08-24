terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}

resource "azurerm_network_security_group" "tf_websrv_nsg" {
  name                = "${var.name}-websrv-nsg"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_network_security_rule" "tf_websrv_nsg_rules" {
  for_each                    = local.websrv_nsg_rules
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.tf_websrv_nsg.name
}

resource "azurerm_network_interface" "tf_websrv_nic" {
  name                = "${var.name}-nic-websrv"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.name}-nic-websrv-cfg"
    subnet_id                     = var.sn_priv_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ip
  }
}

resource "azurerm_network_interface_security_group_association" "tf_websrv_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.tf_websrv_nic.id
  network_security_group_id = azurerm_network_security_group.tf_websrv_nsg.id
}

resource "azurerm_linux_virtual_machine" "tf_websrv" {
  name                            = "${var.name}-vm-websrv"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = "Standard_B1ls"
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data                     = base64encode(file("${path.module}/templates/websrv_cloudinit.yml"))

  network_interface_ids = [
    azurerm_network_interface.tf_websrv_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_key
  }

  os_disk {
    caching              = "None"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

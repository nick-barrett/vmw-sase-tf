/*
Step 1
Create the WAN Network Security Group for the edges
*/

resource "azurerm_network_security_group" "edge_wan_nsg" {
  name                = "${var.name}-wan-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "edge_wan_nsg_rule" {
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
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.edge_wan_nsg.name
}

/*
Step 2
Create the public IP addresses for the edges
*/

resource "azurerm_public_ip" "edge_wan_pub" {
  for_each            = local.edge_data
  name                = "${var.name}-${each.key}-wan-pub"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

/*
Step 3
Create the GE1 (WAN) NICs and associate the NSG to them
*/

resource "azurerm_network_interface" "edge_wan_nic" {
  for_each            = local.edge_data
  name                = "${var.name}-${each.key}-wan-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.name}-${each.key}-wan-nic-cfg"
    subnet_id                     = var.wan_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.edge_wan_pub[each.key].id
  }

  dns_servers = ["8.8.8.8", "8.8.4.4"]
}

resource "azurerm_network_interface_security_group_association" "edge_wan_nsg_assoc" {
  for_each                  = local.edge_data
  network_interface_id      = azurerm_network_interface.edge_wan_nic[each.key].id
  network_security_group_id = azurerm_network_security_group.edge_wan_nsg.id
}

/*
Step 4
Create the GE2 (LAN) NICs
*/

resource "azurerm_network_interface" "edge_lan_nic" {
  for_each             = local.edge_data
  name                 = "${var.name}-${each.key}-lan-nic"
  location             = var.location
  resource_group_name  = var.resource_group_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${var.name}-${each.key}-lan-nic-cfg"
    subnet_id                     = var.lan_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.lan_ip
  }
}

/*
Step 5
Create the availability set
*/

resource "azurerm_availability_set" "edge_availability_set" {
  count               = length(local.edge_data) > 1 ? 1 : 0
  name                = "${var.name}-avail-set"
  location            = var.location
  resource_group_name = var.resource_group_name
}

/*
Step 6
Create the edge VMs
*/

resource "azurerm_linux_virtual_machine" "edge_vm" {
  for_each                        = local.edge_data
  name                            = "${var.name}-${each.key}-vm"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.shell.username
  disable_password_authentication = true
  custom_data                     = each.value.custom_data

  availability_set_id = length(local.edge_data) > 1 ? azurerm_availability_set.edge_availability_set[0].id : null

  network_interface_ids = [
    azurerm_network_interface.edge_wan_nic[each.key].id,
    azurerm_network_interface.edge_lan_nic[each.key].id
  ]

  admin_ssh_key {
    username   = var.shell.username
    public_key = var.shell.ssh_public_key
  }

  os_disk {
    caching              = "None"
    storage_account_type = "StandardSSD_LRS"
  }

  plan {
    name      = "vmware_sdwan_4x"
    product   = "sol-42222-bbj"
    publisher = "vmware-inc"
  }

  source_image_reference {
    publisher = "vmware-inc"
    offer     = "sol-42222-bbj"
    sku       = "vmware_sdwan_4x"
    version   = "4.2.1"
  }
}

# This waits for the VCO to report that the VCE is Connected
resource "null_resource" "wait_for_vce_activation" {
  depends_on = [azurerm_linux_virtual_machine.edge_vm]

  provisioner "local-exec" {
    command = templatefile("${path.module}/scripts/vce_waiter.py", {
      api_url         = "https://${var.vco_url}/portal/rest/edge/getEdge"
      api_key         = var.vco_api_key
      activation_keys = join(",", var.edge_settings.*.activation_code)
    })
    interpreter = [
      "python",
      "-c"
    ]
  }
}

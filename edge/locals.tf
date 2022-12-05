locals {
  edge_data = { for edge in var.edge_settings : edge.name => {
    lan_ip = edge.lan_ip
    custom_data = base64encode(templatefile("${path.module}/templates/vce_customdata.yml", {
      activation_code = "${edge.activation_code}"
      vco_url         = "${var.vco_url}"
    }))
  } }

  wan_nsg_rules = {
    vcmp = {
      name                       = "VCMP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "2426"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    snmp = {
      name                       = "SNMP"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "161"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    ssh = {
      name                       = "SSH"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

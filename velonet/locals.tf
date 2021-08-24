locals {
  # allow for up to 8 subnets in the VNet (using 3 bits for subnet)
  # we only use 2 but leave subnets for extending
  cidr_split = cidrsubnets(var.cidr, 3, 3)

  cidr_dmz  = element(local.cidr_split, 0)
  cidr_priv = element(local.cidr_split, 1)

  vce_ip_priv = cidrhost(local.cidr_priv, 10)

  dns_server_ip = cidrhost(local.cidr_priv, 4)

  vce_userdata = base64encode(templatefile("${path.module}/templates/vce_userdata.yml", {
    activation_code = "${var.activation_code}"
    vco_url         = "${var.vco_url}"
  }))

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

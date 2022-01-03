/*
Step 1
Create the VNet
*/
resource "azurerm_virtual_network" "branch_vnet" {
  name                = "${var.name}-vnet"
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_servers         = var.provision_local_dns ? [local.local_dns_server_ip] : null
}

/*
Step 2
Create the LAN route table to force all traffic through the edge instance
*/
resource "azurerm_route_table" "branch_lan_route_table" {
  name                = "${var.name}-lan-route-table"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.edge_lan_ip
  }
}

/*
Step 3
Create the LAN subnet for the clients to use
*/
resource "azurerm_subnet" "branch_lan_subnet" {
  name                 = "${var.name}-lan-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.branch_vnet.name
  address_prefixes     = [local.lan_address_prefix]
}

resource "azurerm_subnet_route_table_association" "branch_lan_route_table_assoc" {
  subnet_id      = azurerm_subnet.branch_lan_subnet.id
  route_table_id = azurerm_route_table.branch_lan_route_table.id
}

/*
Step 4
Create the WAN subnet for the edge to use for Internet connectivity
*/
resource "azurerm_subnet" "branch_wan_subnet" {
  name                 = "${var.name}-wan-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.branch_vnet.name
  address_prefixes     = [local.wan_address_prefix]
}

/*
Step 5
Create the edge instance
*/
module "edge" {
  source              = "../edge"
  name                = "${var.name}-edge"
  resource_group_name = var.resource_group_name
  location            = var.location
  wan_subnet_id       = azurerm_subnet.branch_wan_subnet.id
  lan_subnet_id       = azurerm_subnet.branch_lan_subnet.id
  vco_url             = var.vco_url
  vco_api_key         = var.vco_api_key
  shell = {
    username       = var.username
    ssh_public_key = var.ssh_public_key
  }
  edge_settings = [{
    name            = "edge"
    lan_ip          = local.edge_lan_ip
    activation_code = var.activation_code
  }]
}

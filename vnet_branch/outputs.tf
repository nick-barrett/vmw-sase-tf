output "vnet_name" {
  value       = azurerm_virtual_network.branch_vnet.name
  description = "Name of the branch VNet"
}

output "lan_subnet_id" {
  value       = azurerm_subnet.branch_lan_subnet.id
  description = "ID of the LAN subnet"
}

output "lan_cidr" {
  value       = local.lan_address_prefix
  description = "CIDR prefix for the LAN subnet"
}

output "dns_server_ip" {
  value       = local.local_dns_server_ip
  description = "IP address assigned as the VNet's DNS server"
}

output "vce_activated" {
  value       = module.edge.edge_activated
  description = "Dummy output indicating that the activation is complete"
}

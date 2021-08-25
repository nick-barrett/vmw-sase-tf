output "private_subnet_id" {
  value = azurerm_subnet.tf_vnet_sn_priv.id
  description = "ID of the private subnet"
}

output "rg_name" {
  value = azurerm_resource_group.tf_rg.name
  description = "Resource group name"
}

output "private_cidr" {
  value = local.cidr_priv
  description = "CIDR prefix for the private subnet"
}

output "dns_server_ip" {
  value = local.dns_server_ip
  description = "IP address that a DNS server should be placed at"
}

output "vce_activated" {
  value = null_resource.wait_for_vce_activation.id
  description = "Dummy output indicating that the activation is complete"
}
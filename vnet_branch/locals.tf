locals {
  all_subnets        = cidrsubnets(var.address_space, 2, 2)
  wan_address_prefix = element(local.all_subnets, 0)
  lan_address_prefix = element(local.all_subnets, 1)

  edge_lan_ip         = cidrhost(local.lan_address_prefix, 4)
  local_dns_server_ip = cidrhost(local.lan_address_prefix, 5)
}

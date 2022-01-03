resource "azurerm_resource_group" "resource_group" {
  name     = "${var.env_name}-rg"
  location = var.location
}

module "sase_velonet" {
  source              = "./vnet_branch"
  name                = "${var.env_name}-net"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  address_space       = var.address_space
  username            = var.ssh_admin_username
  ssh_public_key      = local.ssh_key
  vco_url             = var.vco_url
  vco_api_key         = var.vco_api_key
  activation_code     = var.vce_activation_code
  provision_local_dns = true
}

module "velonet_dc" {
  source              = "./domaincontroller"
  name                = "${var.env_name}-dc"
  computer_name       = var.dc_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  subnet_id           = module.sase_velonet.lan_subnet_id
  vm_size             = var.dc_vm_size
  ip                  = module.sase_velonet.dns_server_ip
  username            = var.windows_admin_username
  password            = var.windows_admin_password
  domain_name         = var.domain_name
  domain_nb_name      = var.domain_netbios_name
  domain_structure    = var.domain_structure

  depends_on = [
    module.sase_velonet.vce_activated
  ]
}

module "velonet_websrv" {
  source              = "./websrv"
  name                = var.env_name
  admin_username      = var.ssh_admin_username
  ssh_key             = local.ssh_key
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  subnet_id           = module.sase_velonet.lan_subnet_id
  ip                  = cidrhost(module.sase_velonet.lan_cidr, 6)

  depends_on = [
    module.sase_velonet.vce_activated,
    module.velonet_dc.domain_controller_complete
  ]
}

module "sase_velonet" {
  source = "./velonet"
  providers = {
    azurerm = azurerm
  }
  name            = var.env_name
  location        = var.location
  cidr            = var.network_cidr
  activation_code = var.vce_activation_key
  admin_username  = var.ssh_admin_username
  ssh_key         = local.ssh_key
  vco_url         = var.vco_url
  vm_size         = var.vce_vm_size
}

# Wait for the VCE activation to complete
# Otherwise web server and DC init scripts fail
# More elegant solution would be to poll the VCE activation state somehow
resource "time_sleep" "vce_activation_delay" {
  depends_on = [module.sase_velonet]

  create_duration = "360s"
}

module "velonet_dc" {
  source = "./domaincontroller"
  providers = {
    azurerm = azurerm
  }
  name           = var.env_name
  computer_name  = var.dc_name
  rg_name        = module.sase_velonet.rg_name
  location       = var.location
  sn_priv_id     = module.sase_velonet.private_subnet_id
  vm_size        = var.dc_vm_size
  ip             = module.sase_velonet.dns_server_ip
  username       = var.windows_admin_username
  password       = var.windows_admin_password
  domain_name    = var.domain_name
  domain_nb_name = var.domain_netbios_name
  domain_structure = var.domain_structure

  depends_on = [
    time_sleep.vce_activation_delay
  ]
}

module "velonet_websrv" {
  source = "./websrv"
  providers = {
    azurerm = azurerm
  }
  name           = var.env_name
  admin_username = var.ssh_admin_username
  ssh_key        = local.ssh_key
  rg_name        = module.sase_velonet.rg_name
  location       = var.location
  sn_priv_id     = module.sase_velonet.private_subnet_id
  ip             = cidrhost(module.sase_velonet.private_cidr, 5)

  depends_on = [
    time_sleep.vce_activation_delay
  ]
}

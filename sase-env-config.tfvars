# Ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
subscription_id = ""
client_id = ""
client_secret = ""
tenant_id = ""

# env_name is a prefix used for the Azure entity names
env_name = "vmw-sase-ncus-env"
# Azure region to deploy into
location = "northcentralus"

# Network to be used for the dedicated demo VNet
network_cidr = "100.66.0.0/21"

# Username for the web server and VCE
ssh_admin_username = ""
# Username for the domain controller administrator
admin_username = ""
# Password for the domain controller administrator
admin_password = ""
# Path to the SSH public key file for the web server and VCE
ssh_keyfile = "~/.ssh/id_rsa.pub"

# DO NOT include the https:// part of URL
vco_url = ""
vce_activation_key = ""
vce_vm_size = "Standard_DS3_v2"

dc_vm_size = "Standard_D2s_v3"
# Hostname of the domain controller
dc_name = ""
# Domain to be used for the active directory environment
domain_name = ""
# NetBIOS domain name for the active directory environment
# MUST BE 15 characters or less
domain_netbios_name = ""

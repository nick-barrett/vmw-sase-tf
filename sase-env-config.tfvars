# Ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
subscription_id = ""
client_id = ""
client_secret = ""
tenant_id = ""

env_name = "vmw-sase-ncus-env"
location = "northcentralus"

network_cidr = "100.66.0.0/21"

ssh_admin_username = ""
admin_username = ""
admin_password = ""
ssh_keyfile = "~/.ssh/id_rsa.pub"

# DO NOT include the https:// part of URL
vco_url = ""
vce_activation_key = ""
vce_vm_size = "Standard_DS3_v2"

dc_vm_size = "Standard_D2s_v3"
# Hostname of the domain controller
dc_name = ""
domain_name = ""
# MUST BE 15 characters or less
domain_netbios_name = ""

# Service principal for Azure
variable "subscription_id" {
  type = string
  description = "Subscription ID for the Azure account"
}
variable "client_id" {
  type = string
  description = "Client ID for the Azure service principal"
}
variable "client_secret" {
  type = string
  description = "Client secret for the Azure service principal"
}
variable "tenant_id" {
  type = string
  description = "Azure AD tenant ID"
}

variable "env_name" {
  type = string
  description = "Short name used as a prefix for object names"
}

variable "location" {
  type = string
  description = "Azure region for the environment i.e. northcentralus"
}

variable "network_cidr" {
  type = string
  description = "CIDR block for the VNet"
}

variable "vco_url" {
  type = string
  description = "URL of the VCO to activate against"
}

variable "vce_activation_key" {
  type = string
  description = "Activation key for the VCE"
}

variable "vce_vm_size" {
  type = string
  description = "VM model for the VCE. Check VMware documentation."
}

variable "dc_vm_size" {
  type = string
  description = "VM model for the domain controller"
}

variable "ssh_keyfile" {
  type = string
  description = "Path to the key file containing the desired public key"
}

variable "ssh_admin_username" {
  type = string
  description = "Initial administrator username for the VCE and web server"
}

variable "windows_admin_username" {
  type = string
  description = "Initial administrator username for the domain controller"
}

variable "windows_admin_password" {
  type = string
  description = "Password for the domain controller admin"
}

variable "dc_name" {
  type = string
  description = "Host name of the domain controller"
}

variable "domain_name" {
  type = string
  description = "Domain name to use when deploying the domain controller"
}

variable "domain_netbios_name" {
  type = string
  description = "Domain NetBIOS name to use when deploying the domain controller"
}
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

variable "address_space" {
  type = string
  description = "CIDR block for the VNet"
}

variable "vco_url" {
  type = string
  description = "URL of the VCO to activate against"
}

variable "vco_api_key" {
  type = string
  description = "An API key for the VCO in use. This needs to be at the enterprise level"
}

variable "vce_activation_code" {
  type = string
  description = "Activation code for the VCE"
}

variable "vce_vm_size" {
  type        = string
  description = "Edge instance size"
  default     = "Standard_D2s_v4"
  validation {
    condition     = contains(["Standard_D2s_v4", "Standard_D4s_v4", "Standard_D8s_v4"], var.vce_vm_size)
    error_message = "Invalid edge instance size provided."
  }
}

variable "dc_vm_size" {
  type = string
  default = "Standard_D2s_v4"
  description = "Domain controller instance size"
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
  validation {
    condition = length(var.domain_netbios_name) >= 1 && length(var.domain_netbios_name) < 16
    error_message = "Domain NetBIOS name must be less than 16 characters."
  }
}

variable "domain_structure" {
  type = object({
    ous = list(object({
      name = string
      path = string
    }))
    users = list(object({
      name = string
      given_name = string
      surname = string
      sam_account_name = string
      upn = string
      path = string
      display_name = string
      password = string
    }))
    groups = list(object({
      name = string
      sam_account_name = string
      display_name = string
      path = string
      description = string
      members = string
    }))
  })
  description = "OU, group, and user definitions"
}
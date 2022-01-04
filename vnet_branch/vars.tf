variable "name" {
  type        = string
  description = "Prefix to use for Azure resource names"
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group to deploy into"
}

variable "location" {
  type        = string
  description = "Azure location to deploy into"
}

variable "address_space" {
  type        = string
  description = "IP space for the vHub VNet to use (/24 or larger)"
}

variable "vm_size" {
  type        = string
  description = "Edge instance size"
  default     = "Standard_D2s_v4"
  validation {
    condition     = contains(["Standard_D2s_v4", "Standard_D4s_v4", "Standard_D8s_v4"], var.vm_size)
    error_message = "Invalid edge instance size provided."
  }
}

variable "vco_url" {
  type        = string
  description = "URL of the VCO; do NOT include https://"
  validation {
    condition     = !can(regex("^https?\\:\\/\\/", var.vco_url))
    error_message = "Invalid VCO URL provided."
  }
}

variable "vco_api_key" {
  type = string
  description = "An API key for the VCO in use. This needs to be at the enterprise level"
}

variable "username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "activation_code" {
  type = string
  validation {
    condition     = can(regex("^(?:[A-Z\\d]{4}\\-){3}[A-Z\\d]{4}$", var.activation_code))
    error_message = "Invalid edge activation code provided."
  }
}

variable "provision_local_dns" {
  type = bool
  description = "Reserve an IP for a local DNS server to apply to the VNet?"
  default = false
}

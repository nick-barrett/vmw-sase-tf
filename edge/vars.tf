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

variable "wan_subnet_id" {
  type        = string
  description = "ID of the GE2 (WAN) subnet"
}

variable "lan_subnet_id" {
  type        = string
  description = "ID of the GE3 (LAN) subnet"
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

variable "shell" {
  type = object({
    username = string
    ssh_public_key = string
  })
  description = "Username and public SSH key for shell access into the edge VMs"
}

variable "edge_settings" {
  type = set(object({
    name            = string
    lan_ip          = string
    activation_code = string
  }))
  description = "LAN IP and activation codes for each edge"
  validation {
    condition     = alltrue([for edge in var.edge_settings : can(regex("^(?:[A-Z\\d]{4}\\-){3}[A-Z\\d]{4}$", edge.activation_code))])
    error_message = "Invalid edge activation code provided."
  }
}

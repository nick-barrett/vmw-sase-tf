variable "name" {
  type = string
  description = "Name for this VMware SD-WAN VNet instance"
}

variable "location" {
  type = string
  description = "Azure region for this VMware SD-WAN VNet"
}

variable "cidr" {
    type = string
    description = "CIDR network for this VNet to use"
}

variable "vm_size" {
    type = string
    description = "VM model to use for the VCE i.e. Standard_DS3_v2"
}

variable "admin_username" {
    type = string
    description = "Username for the initial user. Usually vcadmin."
}
variable "ssh_key" {
    type = string
    description = "Public SSH key for the VCE vcadmin user"
}

variable "vco_url" {
    type = string
    description = "URL of the VCO to activate against - do NOT include https://"
}

variable "activation_code" {
    type = string
    description = "Activation code for the VCE"
}
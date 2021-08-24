variable "name" {
  type = string
  description = "Name prefix for this instance"
}

variable "rg_name" {
    type = string
    description = "Resource group name"
}

variable "sn_priv_id" {
  type = string
  description = "ID of the subnet for the domain controller to be placed in"
}

variable "location" {
  type = string
  description = "Location for the domain controller"
}

variable "username" {
  type = string
  description = "Admin username"
}

variable "password" {
  type = string
  description = "Admin password"
}

variable "domain_name" {
  type = string
  description = "Active directory domain name"
}

variable "domain_nb_name" {
  type = string
  description = "NetBIOS domain name for the domain controller"
}

variable "vm_size" {
  type = string
  description = "VM size to use for the domain controller"
}

variable "ip" {
  type = string
  description = "IP address for the domain controller"
}

variable "computer_name" {
  type = string
  description = "Computer name for the domain controller"
}
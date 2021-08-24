variable "name" {
  type = string
  description = "Name prefix for this instance"
}

variable "rg_name" {
    type = string
    description = "Resource group name"
}

variable "admin_username" {
  type = string
  description = "Username for the initial user"
}

variable "ssh_key" {
    type = string
    description = "Public SSH key for the web server azuser account"
}

variable "sn_priv_id" {
  type = string
  description = "ID of the subnet for the web server to be placed in"
}

variable "location" {
  type = string
  description = "Location for the web server"
}

variable "ip" {
  type = string
  description = "IP address of the web server"
}

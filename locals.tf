locals {
    # This must be done here - tfvars cannot use functions
    ssh_key = file(var.ssh_keyfile)
}
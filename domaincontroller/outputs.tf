output "domain_controller_complete" {
  value = azurerm_virtual_machine_extension.tf_dc_setup_script.id
  description = "Dummy output to indicate that the VM extension deployment is done"
}
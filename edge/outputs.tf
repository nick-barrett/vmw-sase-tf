output "edge_activated" {
  value = null_resource.wait_for_vce_activation.id
  description = "Dummy output indicating that the activation is complete"
}
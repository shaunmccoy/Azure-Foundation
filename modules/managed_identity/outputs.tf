output "id" {
  description = "Identity resource ID."
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "Object ID of the identity's service principal."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "Client (application) ID of the identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

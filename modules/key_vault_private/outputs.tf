output "id" {
  description = "Key Vault resource ID."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Vault URI."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_ip_address" {
  description = "Private IP of the vault's private endpoint."
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}

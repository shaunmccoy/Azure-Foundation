output "id" {
  description = "Recovery Services vault resource ID."
  value       = azurerm_recovery_services_vault.this.id
}

output "name" {
  description = "Recovery Services vault name."
  value       = azurerm_recovery_services_vault.this.name
}

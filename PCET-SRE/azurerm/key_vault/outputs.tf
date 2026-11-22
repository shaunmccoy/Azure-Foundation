output "key_vault" {
  description = "This contains all resources in this module."
  value       = [azurerm_key_vault.key_vault
    , azurerm_key_vault_access_policy.key_vault
    , azurerm_private_endpoint.key_vault
    , azurerm_monitor_diagnostic_setting.key_vault_diag]
}
output "linux_private_ip_address" {
  description = "Private IP address of the Linux test VM."
  value       = azurerm_linux_virtual_machine.linux.private_ip_address
}

output "windows_private_ip_address" {
  description = "Private IP address of the Windows test VM."
  value       = azurerm_windows_virtual_machine.windows.private_ip_address
}

output "credential_secret_names" {
  description = "Key Vault secrets that hold the test VM credentials."
  value = {
    linux_ssh_private_key  = azurerm_key_vault_secret.linux_ssh_private_key.name
    windows_admin_password = azurerm_key_vault_secret.windows_admin_password.name
  }
}

output "cognitive_service_endpoint" {
  description = "Endpoint of the private-link test target, when enabled."
  value       = one(azurerm_cognitive_account.test[*].endpoint)
}

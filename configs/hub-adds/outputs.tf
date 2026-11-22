output "domain_controllers" {
  description = "Map of domain controller name to private IP address."
  value       = { for name, vm in local.domain_controllers : name => vm.ip_address }
}

output "admin_password_secret_names" {
  description = "Key Vault secret names that hold each domain controller's local administrator password."
  value       = { for name, secret in azurerm_key_vault_secret.admin_password : name => secret.name }
}

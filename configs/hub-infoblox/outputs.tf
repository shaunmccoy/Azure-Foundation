output "appliances" {
  description = "Map of appliance name to private IP address. These are the DNS servers handed to the virtual networks."
  value       = { for vm in local.appliances : vm.name => vm.ip_address }
}

output "admin_password_secret_names" {
  description = "Key Vault secret names that hold each appliance's administrator password."
  value       = { for key, secret in azurerm_key_vault_secret.admin_password : local.appliances[key].name => secret.name }
}

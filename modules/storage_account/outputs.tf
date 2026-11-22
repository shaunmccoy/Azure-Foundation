output "id" {
  description = "Storage account resource ID."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint URL."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_web_host" {
  description = "Host name of the static website endpoint."
  value       = azurerm_storage_account.this.primary_web_host
}

output "private_ip_addresses" {
  description = "Map of sub-resource to private endpoint IP."
  value       = { for k, pe in azurerm_private_endpoint.this : k => pe.private_service_connection[0].private_ip_address }
}

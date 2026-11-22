output "resource_id" {
  value = azurerm_storage_account.storage.id
}

output "storage_account" {
  value = azurerm_storage_account.storage
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output storage_account_private_ip {
  value = azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address
}

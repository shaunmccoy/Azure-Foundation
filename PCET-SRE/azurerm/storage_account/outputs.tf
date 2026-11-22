output "storage_id" {
    description = "This will return the id of newly created storage"
    value = azurerm_storage_account.storage.id
}
output "storage_primary_location" {
    description = "This will return the id of newly created storage"
    value = azurerm_storage_account.storage.primary_location
}
output "storage_secondary_location" {
    description = "This will return the id of newly created storage"
    value = azurerm_storage_account.storage.secondary_location
}
output "storage_primary_blob_endpoint" {
    description = "This will return the id of newly created storage"
    value = azurerm_storage_account.storage.primary_blob_endpoint
}
output "primary_access_key" {
    description = "This will return the id of newly created storage"
    value = azurerm_storage_account.storage.primary_access_key 
}

output "storage_account_name" {
    description = "This will return the id of newly created storage"
    value = azurerm_storage_account.storage.name
}
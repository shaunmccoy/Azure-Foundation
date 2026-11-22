output id {
    description = "This will return the id of newly created storage"
    value = azurerm_storage_account.storage.id
}
output name {
    value = azurerm_storage_account.storage.name
}
output storage_primary_location {
    value = azurerm_storage_account.storage.primary_location
}
output storage_secondary_location {
    value = azurerm_storage_account.storage.secondary_location
}
output storage_primary_blob_endpoint {
    value = azurerm_storage_account.storage.primary_blob_endpoint
}
output storage_primary_access_key {
    value = azurerm_storage_account.storage.primary_access_key
}

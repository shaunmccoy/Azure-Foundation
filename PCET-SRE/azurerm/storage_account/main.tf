
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  tags                     = var.tags
  blob_properties {
   
    dynamic "cors_rule" {
      for_each = var.cors
       content {
        allowed_headers = cors_rule.value.allowed_headers
        allowed_methods = cors_rule.value.allowed_methods
        allowed_origins = cors_rule.value.allowed_origins
        exposed_headers = cors_rule.value.exposed_headers
        max_age_in_seconds = cors_rule.value.max_age_in_seconds
    }
}
}
}
resource "azurerm_storage_container" "new" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}


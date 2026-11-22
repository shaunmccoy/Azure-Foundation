resource "azurerm_storage_account" "terraform_state" {
  name                     = lower(var.name)
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_kind             = "Storage"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"
  enable_blob_encryption   = true
  tags                     = var.tags
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = "terraform-state"
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}
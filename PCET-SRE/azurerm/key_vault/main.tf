resource "azurerm_key_vault" "key_vault" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name
  tags                        = var.tags
}

resource "azurerm_key_vault_access_policy" "key_vault" {
  key_vault_id       = azurerm_key_vault.key_vault.id
  tenant_id          = var.tenant_id
  object_id          = var.object_id
  key_permissions    = var.key_permissions
  secret_permissions = var.secret_permissions
}

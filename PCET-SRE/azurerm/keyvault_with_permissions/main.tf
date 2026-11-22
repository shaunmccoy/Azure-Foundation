
data "azurerm_client_config" "current"{
}

resource "azurerm_key_vault" "keyvault" {
  name                            = var.kv_name
  location                        = var.location
  resource_group_name             = var.resource_group_name

  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  soft_delete_enabled             = var.soft_delete_enabled     

  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  tags                            = var.tags

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# Create a Default Azure Key Vault access policy with Admin permissions
# This policy is needed for a proper run of the "destroy" process
# Let current service principal has access to keyvault
resource "azurerm_key_vault_access_policy" "keyvault_default_policy" {
  
  key_vault_id = azurerm_key_vault.keyvault.id
  
   lifecycle {
    create_before_destroy = true
  }
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.key_object_id

  key_permissions = var.keyvault_key_full_permissions
  secret_permissions = var.keyvault_secret_full_permissions
  certificate_permissions = var.keyvault_certificate_full_permissions
  storage_permissions = var.keyvault_storage_full_permissions

}

# Create an Azure Key Vault access policies for rest of the cases, there could be many
resource "azurerm_key_vault_access_policy" "policy" {
  for_each                = var.policies
  key_vault_id            = azurerm_key_vault.keyvault.id
  tenant_id               = lookup(each.value, "tenant_id")
  object_id               = lookup(each.value, "object_id")
  key_permissions         = lookup(each.value, "key_permissions")
  secret_permissions      = lookup(each.value, "secret_permissions")
  certificate_permissions = lookup(each.value, "certificate_permissions")
  storage_permissions     = lookup(each.value, "storage_permissions")
}
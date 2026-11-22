# Create an Azure Key Vault secrets 1
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.keyvault_secrets
  key_vault_id = var.key_vault_id
  name         = each.key
  value        = lookup(each.value, "value")
  
  tags         = var.tags
}
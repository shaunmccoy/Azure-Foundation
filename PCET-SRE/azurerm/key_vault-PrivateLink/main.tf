locals {
  # Common tags to be assigned to all resources
  common_tags = {
    TLA          = var.tla
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_subnet" "keyvault" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_resource_group" "keyvault" {
  name     = var.resource_group_name
}

resource "azurerm_key_vault" "keyvault" {
  name                        = var.kv_name
  location                    = data.azurerm_resource_group.keyvault.location
  resource_group_name         = data.azurerm_resource_group.keyvault.name
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true
  enabled_for_template_deployment = true 
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
 tags = {
    TLA          = var.tla
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
  }
}

resource "azurerm_key_vault_access_policy" "keyvault" {
  key_vault_id = azurerm_key_vault.keyvault.id
  
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = var.object_id

  key_permissions = [
    "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey"
  ]

  secret_permissions = [
    "backup", "delete", "get", "list", "purge", "recover", "restore", "set"
  ]
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = azurerm_key_vault.keyvault.name
  location            = data.azurerm_resource_group.keyvault.location
  resource_group_name = data.azurerm_resource_group.keyvault.name
  subnet_id           = data.azurerm_subnet.keyvault.id

  private_service_connection {
    name                           = azurerm_key_vault.keyvault.name
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
}


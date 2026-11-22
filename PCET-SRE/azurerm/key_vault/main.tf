locals {
  # Needed as dynamic blocks *only* accept maps for for_each
    secure_resources_map = var.secure_resources ? { one = "one"} : {}

    local_object_id_list = length(var.object_id_list) > 0 ? var.object_id_list : [data.azurerm_client_config.current.object_id]

    # needed for the dynamic block for log analytics
    log_category_map = {
        for category in var.diagnostic_log_category_list:
            category => category
    }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days

  # Only 0 or 1 entry depending on var.secure_resources
  dynamic "network_acls" {
    for_each = local.secure_resources_map
    content {
      default_action = "Deny"
      bypass         = "AzureServices"
    }
  }

  tags                        = var.tags
}

resource "azurerm_key_vault_access_policy" "key_vault" {
  count               = length(local.local_object_id_list)

  key_vault_id        = azurerm_key_vault.key_vault.id
  tenant_id           = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  object_id           = local.local_object_id_list[count.index]
  application_id      = var.application_id

  key_permissions           = var.key_permissions
  secret_permissions        = var.secret_permissions
  certificate_permissions   = var.certificate_permissions 
  storage_permissions       = var.storage_permissions
}

resource "azurerm_private_endpoint" "key_vault" {
  name                      = "PRIVATELINK-VAULT-${upper(azurerm_key_vault.key_vault.name)}"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  subnet_id                 = var.subnet_id
  tags                      = var.tags
  
  private_service_connection {
      name                           = azurerm_key_vault.key_vault.name
      private_connection_resource_id = azurerm_key_vault.key_vault.id
      is_manual_connection           = false
      subresource_names              = ["vault"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "key_vault_diag" {
  name                            = var.diagnostics_name
  count                           = var.log_analytics_workspace_id == "" ? 0 : 1
  target_resource_id              = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id      = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days = var.log_analytics_retention_days
    }
  }

  dynamic "log" {
    for_each = local.log_category_map
    content {
        category = log.key
        enabled  = true

        retention_policy {
          enabled = true
          days = var.log_analytics_retention_days
        }
    }
  }
}

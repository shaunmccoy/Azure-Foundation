locals {
    log_category_map = {
          for category in var.diagnostic_log_category_list:
              category => category
    }
}

resource "azurerm_recovery_services_vault" "vault" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vault_sku

  soft_delete_enabled = var.soft_delete_enabled
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "recovery_vault_diag" {
  name                            = var.diagnostics_name
  depends_on                      = [ azurerm_recovery_services_vault.vault ]
  count                           = var.log_analytics_workspace_id == "" ? 0 : 1

  target_resource_id              = azurerm_recovery_services_vault.vault.id
  log_analytics_workspace_id      = var.log_analytics_workspace_id

  # Note: Recovery Services vaults do *not* support Metrics
  
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
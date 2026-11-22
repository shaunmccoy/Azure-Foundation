locals {
  log_category_map = {
      for category in var.diagnostic_log_category_list:
          category => category
  }
}

resource "azurerm_bot_web_app" "bot" {
  name                = var.bot_name
  location            = var.global_app_ind ? "global" : var.location
  resource_group_name = var.resource_group_name
  sku                 = var.bot_sku
  microsoft_app_id    = var.bot_application_id
  endpoint            = var.bot_endpoint

  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "bot_diag" {
  name                            = var.diagnostics_name
  depends_on                      = [ azurerm_bot_web_app.bot ]
  count                           = var.log_analytics_workspace_id == "" ? 0 : 1
  target_resource_id              = azurerm_bot_web_app.bot.id
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  log_analytics_destination_type  = "AzureDiagnostics"

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
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
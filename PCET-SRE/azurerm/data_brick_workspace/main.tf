locals {
  # needed for the dynamic block for log analytics
    log_category_map = {
        for category in var.diagnostic_log_category_list:
            category => category
    }

}

resource "azurerm_databricks_workspace" "workspace" {
  name                = var.data_brick_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.data_brick_workplace_sku
  
  managed_resource_group_name = var.managed_resource_group_name
  
  custom_parameters {
    no_public_ip        = true
    virtual_network_id  = var.virtual_network_id
    public_subnet_name  = var.public_subnet_name
    private_subnet_name = var.private_subnet_name
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "data_brick_diag" {
  name                            = var.diagnostics_name
  count                           = var.log_analytics_workspace_id == "" ? 0 : 1
  target_resource_id              = azurerm_databricks_workspace.workspace.id
  log_analytics_workspace_id      = var.log_analytics_workspace_id

  # Data Bricks des *not* support metrics.

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
resource "azurerm_recovery_services_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  storage_mode_type            = var.storage_mode_type
  cross_region_restore_enabled = var.storage_mode_type == "GeoRedundant" && var.cross_region_restore_enabled
  immutability                 = var.immutability

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_recovery_services_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Resource-specific tables are what the Backup and Site Recovery reports read.
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }
}

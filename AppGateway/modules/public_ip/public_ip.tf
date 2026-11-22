resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.allocation_method       # e.g. Static, Dynamic
  sku                 = var.public_ip_sku           # e.g. Standard, Basic
}

resource "azurerm_monitor_diagnostic_setting" "public_ip_logs" {
  name                            = "${var.public_ip_name}-DIAG"
  target_resource_id              = azurerm_public_ip.public_ip.id
  log_analytics_workspace_id      = var.log_analytics_workspace_id

  metric {
    category  = "AllMetrics"
    enabled   = true
    retention_policy {
      enabled = false
      days = 0
    }
  }

  log {
    category  = "DDoSProtectionNotifications"
    enabled   = true
    retention_policy {
      enabled = false
      days = 0
    }
  }

  log {
    category  = "DDoSMitigationFlowLogs"
    enabled   = true
    retention_policy {
      enabled = false
      days = 0
    }
  }

  log {
    category  = "DDoSMitigationReports"
    enabled   = true
    retention_policy {
      enabled = false
      days = 0
    }
  }
}
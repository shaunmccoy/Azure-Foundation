resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_api_management.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Resource-specific tables (ApiManagementGatewayLogs) instead of AzureDiagnostics.
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_application_insights" "this" {
  count = var.application_insights_enabled ? 1 : 0

  name                = "${var.name}-APPINSIGHTS"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id
  tags                = var.tags

  # Entra ID ingestion only; the instrumentation key alone cannot write telemetry.
  local_authentication_enabled = false
}

resource "azurerm_role_assignment" "application_insights" {
  count = var.application_insights_enabled ? 1 : 0

  scope                = azurerm_application_insights.this[0].id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_api_management_logger" "application_insights" {
  count = var.application_insights_enabled ? 1 : 0

  name                = "applicationinsights"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  resource_id         = azurerm_application_insights.this[0].id

  application_insights {
    connection_string  = azurerm_application_insights.this[0].connection_string
    identity_client_id = azurerm_user_assigned_identity.this.client_id
  }

  depends_on = [azurerm_role_assignment.application_insights]
}

# Service-wide request tracing with W3C correlation, so calls can be followed
# from the edge through the gateway into the backends.
resource "azurerm_api_management_diagnostic" "application_insights" {
  count = var.application_insights_enabled ? 1 : 0

  identifier               = "applicationinsights"
  resource_group_name      = var.resource_group_name
  api_management_name      = azurerm_api_management.this.name
  api_management_logger_id = azurerm_api_management_logger.application_insights[0].id

  sampling_percentage       = var.application_insights_sampling_percentage
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "information"
  http_correlation_protocol = "W3C"
  metrics_enabled           = true
}

locals {
  metric_alerts = var.alerts == null ? {} : {
    "Capacity" = {
      description = "Gateway capacity is high in at least one region; add scale units before requests are throttled."
      metric      = "Capacity", aggregation = "Average", operator = "GreaterThan", threshold = var.alerts.capacity_percent
      severity    = 2, window = "PT30M", frequency = "PT5M"
      dimensions  = { Location = ["*"] }
    }
    "Gateway-5xx" = {
      description = "The gateway is returning server errors."
      metric      = "Requests", aggregation = "Total", operator = "GreaterThan", threshold = var.alerts.gateway_5xx_per_5_minutes
      severity    = 1, window = "PT5M", frequency = "PT1M"
      dimensions  = { GatewayResponseCodeCategory = ["5xx"] }
    }
    "Backend-Duration" = {
      description = "Backends are responding slowly."
      metric      = "BackendDuration", aggregation = "Average", operator = "GreaterThan", threshold = var.alerts.backend_duration_ms
      severity    = 2, window = "PT15M", frequency = "PT5M"
      dimensions  = { Location = ["*"] }
    }
    "Unauthorized" = {
      description = "Spike in unauthorized gateway requests: expired credentials, misconfiguration or probing."
      metric      = "Requests", aggregation = "Total", operator = "GreaterThan", threshold = var.alerts.unauthorized_per_5_minutes
      severity    = 3, window = "PT5M", frequency = "PT5M"
      dimensions  = { GatewayResponseCode = ["401", "403"] }
    }
  }
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each = local.metric_alerts

  name                = "${var.name} - ${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_api_management.this.id]
  description         = each.value.description
  severity            = each.value.severity
  window_size         = each.value.window
  frequency           = each.value.frequency
  auto_mitigate       = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ApiManagement/service"
    metric_name      = each.value.metric
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold

    dynamic "dimension" {
      for_each = each.value.dimensions

      content {
        name     = dimension.key
        operator = "Include"
        values   = dimension.value
      }
    }
  }

  action {
    action_group_id = var.alerts.action_group_id
  }
}

# Platform-reported health: fires when Azure itself marks the service degraded or unavailable.
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  count = var.alerts == null ? 0 : 1

  name                = "${var.name} - Resource Health"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [azurerm_api_management.this.id]
  description         = "Azure Resource Health reports the API Management service degraded or unavailable."
  tags                = var.tags

  criteria {
    category = "ResourceHealth"

    resource_health {
      current  = ["Degraded", "Unavailable"]
      previous = ["Available"]
    }
  }

  action {
    action_group_id = var.alerts.action_group_id
  }
}

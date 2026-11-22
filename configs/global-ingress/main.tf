# Global entry point: DNS-based routing across the regional Application Gateways.
# With the defaults a failed region is taken out of DNS in about 30 seconds
# (10 s probes, 2 tolerated failures) and clients follow within the 30 s TTL.

resource "azurerm_resource_group" "global_ingress" {
  name     = "${local.prefix}-GLOBAL-INGRESS-RG"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = "${local.prefix}-TRAFFIC-MANAGER"
  resource_group_name    = azurerm_resource_group.global_ingress.name
  traffic_routing_method = var.routing_method
  tags                   = local.common_tags

  dns_config {
    relative_name = var.dns_relative_name
    ttl           = var.dns_ttl
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = var.health_probe.path
    interval_in_seconds          = var.health_probe.interval_in_seconds
    timeout_in_seconds           = var.health_probe.timeout_in_seconds
    tolerated_number_of_failures = var.health_probe.tolerated_failures
    expected_status_code_ranges  = ["200-399"]

    # Probes arrive by IP; the header selects the right listener on the gateway.
    custom_header {
      name  = "host"
      value = var.health_probe.host_header
    }
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "this" {
  for_each = var.endpoints

  name               = each.key
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = each.value.public_ip_id
  priority           = each.value.priority
  weight             = each.value.weight
  enabled            = each.value.enabled
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_traffic_manager_profile.this.id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Fires per endpoint, so the page says which region dropped out.
resource "azurerm_monitor_metric_alert" "endpoint_down" {
  count = var.alert_action_group_id == null ? 0 : 1

  name                = "${local.prefix} - Global ingress endpoint unhealthy"
  resource_group_name = azurerm_resource_group.global_ingress.name
  scopes              = [azurerm_traffic_manager_profile.this.id]
  description         = "A regional Application Gateway is failing Traffic Manager health probes and is out of rotation."
  severity            = 1
  window_size         = "PT5M"
  frequency           = "PT1M"
  auto_mitigate       = true
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Network/trafficManagerProfiles"
    metric_name      = "ProbeAgentCurrentEndpointStateByProfileResourceId"
    aggregation      = "Maximum"
    operator         = "LessThan"
    threshold        = 1

    dimension {
      name     = "EndpointName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = var.alert_action_group_id
  }
}

locals {
    # "tag1": "example"
    event_grid_tag_list   = [for k,v in var.tags: format("\"%s\": \"%s\"", k, v)]
    tags_json               = join(",", local.event_grid_tag_list)

    event_grid_arm = templatefile("${path.module}/eventGridSystemTopic.json", {event_grid_name = var.event_grid_name, location = var.location, tags_json = local.tags_json, event_source_resource_id = var.event_source_resource_id, event_source_topic_type = var.event_source_topic_type})

    event_grid_resource_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.EventGrid/systemTopics/${var.event_grid_name}"
}

resource "azurerm_resource_group_template_deployment" "event_grid" {
  name                = var.deployment_name
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = local.event_grid_arm
  debug_level         = "requestContent, responseContent"
}

resource "azurerm_monitor_diagnostic_setting" "event_grid_diag" {
  name                            = var.diagnostics_name
  depends_on                      = [ azurerm_resource_group_template_deployment.event_grid ]
  count                           = var.log_analytics_workspace_id == "" ? 0 : 1
  target_resource_id              = local.event_grid_resource_id
  log_analytics_workspace_id      = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
      days = var.log_analytics_retention_days
    }
  }

  # only one log category available for event grid system topics
  log {
    category = "DeliveryFailures"
    enabled  = true

    retention_policy {
      enabled = true
      days = var.log_analytics_retention_days
    }
  }

}
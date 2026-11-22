locals {
    # "tag1": "example"
    data_factory_tag_list   = [for k,v in var.tags: format("\"%s\": \"%s\"", k, v)]
    tags_json               = join(",", local.data_factory_tag_list)
    log_category_map = {
        for category in var.diagnostic_log_category_list:
            category => category
    }

    gitConfigureLater = var.devops_configure_later ? "true" : "false"

    data_factory_parms = templatefile("${path.module}/parameters-template.json", {data_factory_name = var.data_factory_name, location = var.location, devops_account_name = var.devops_account_name, devops_project_name = var.devops_project_name, devops_repo_name = var.devops_repo_name, devops_branch_name = var.devops_branch_name, devops_root_folder = var.devops_root_folder, gitConfigureLater = local.gitConfigureLater, tags_json = local.tags_json})

    data_factory_resource_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DataFactory/factories/${var.data_factory_name}"
}

resource "azurerm_resource_group_template_deployment" "data_factory" {
  name                = var.deployment_name
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  parameters_content  = local.data_factory_parms
  template_content    = file("${path.module}/arm_template.json")
  debug_level         = "requestContent, responseContent"
}

resource "azurerm_private_endpoint" "data_factory" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  depends_on          = [ azurerm_resource_group_template_deployment.data_factory ]

  private_service_connection {
    name                           = var.data_factory_name
    private_connection_resource_id = local.data_factory_resource_id
    is_manual_connection           = false
    subresource_names              = ["dataFactory"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "data_factory_diag" {
  name                            = var.diagnostics_name
  depends_on                      = [ azurerm_resource_group_template_deployment.data_factory ]
  count                           = var.log_analytics_workspace_id == "" ? 0 : 1
  target_resource_id              = local.data_factory_resource_id
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
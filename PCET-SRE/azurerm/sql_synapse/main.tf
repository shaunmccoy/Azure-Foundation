locals {
  # needed for the dynamic block for log analytics
  synapse_log_category_map = {
    for category in var.synapse_diagnostic_log_category_list :
    category => category
  }

  sqlpool_log_category_map = {
    for category in var.sqlpool_diagnostic_log_category_list :
    category => category
  }
}

#add storage account - can't have workspace without storage account 
resource "azurerm_storage_account" "examplesqlsynapsesa" {
  name                     = "examplesqlsynapsesa"
  resource_group_name      = var.resource_group_name
  location                 = "centralus"
  account_replication_type = "LRS"
  account_tier             = "standard"

}
resource "azurerm_storage_data_lake_gen2_filesystem" "datalakegen2fs1" {
  name               = "datalakegen2fs1"
  storage_account_id = azurerm_storage_account.sqlsynapsesa.id
  #storage_account_name = azurerm_storage_account.example_sql_synapse_storage_account.name 
}

resource "azurerm_synapse_workspace" "synapseworkspace" {
  name                                 = "synapseworkspace"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.datalakegen2fs1.id
  sql_administrator_login              = var.sql_administrator_login
  sql_administrator_login_password     = "REPLACE_ME"

  tags = var.tags
}

resource "azurerm_synapse_sql_pool" "synapse_sql_pool" {
  count = var.synapse_sql_pool_name != null ? 1 : 0

  name                 = var.synapse_sql_pool_name
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  sku_name             = var.sql_pool_sku_name
}

#how do we lock this down? is a firewall rule required? 
resource "azurerm_synapse_firewall_rule" "synapseFireWallRule1" {
  name                 = "synapseFireWallRule1"
  synapse_workspace_id = azurerm_synapse_workspace.synapseworkspace.id
  start_ip_address     = ""
  end_ip_address       = ""
}

###azurerm_synapse_managed_private_endpoint section###

/*resource "azurerm_synapse_managed_private_endpoint" "endpoint1" {
  name                 = var.managed_private_endpoint_name
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  target_resource_id   = azurerm_synapse_workspace.synapse_workspace.id
  subresource_name     = var.subresource_name

  #depends_on = [azurerm_synapse_firewall_rule.synapseFireWallRule1]
}*/

###azurerm_synapse_role_assignment section###
#data "azurerm_client_config" "current" {}

resource "azurerm_synapse_role_assignment" "WorkspaceAdmin" {
  synapse_workspace_id = azurerm_synapse_workspace.synapseworkspace.id
  role_name            = var.role_name
  principal_id         = var.principal_id

  #depends_on = [azurerm_synapse_firewall_rule.synapseFireWallRule1]
}

resource "azurerm_monitor_diagnostic_setting" "synapse_diag" {
  name                       = var.diagnostics_name
  count                      = var.log_analytics_workspace_id == "" ? 0 : 1
  target_resource_id         = azurerm_synapse_workspace.synapse_workspace.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  dynamic "log" {
    for_each = local.synapse_log_category_map
    content {
      category = log.key
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_analytics_retention_days
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "synapse_diag" {
  name                       = var.diagnostics_name
  count                      = var.log_analytics_workspace_id == "" ? 0 : 1
  target_resource_id         = azurerm_synapse_workspace.synapseworkspace.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Synapse does not support metrics

  dynamic "log" {
    for_each = local.log_category_map
    content {
      category = log.key
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_analytics_retention_days
      }
    }
  }
}

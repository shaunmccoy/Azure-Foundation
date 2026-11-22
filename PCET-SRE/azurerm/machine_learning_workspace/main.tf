locals {
  # "tag1": "example"
    machine_learning_tag_list   = [for k,v in var.tags: format("\"%s\": \"%s\"", k, v)]
    tags_json               = join(",", local.machine_learning_tag_list)

  # needed for the dynamic block for log analytics
    ml_log_category_map = {
        for category in var.machine_learning_diagnostic_log_category_list:
            category => category
    }
    vault_log_category_map = {
        for category in var.vault_diagnostic_log_category_list:
            category => category
    } 
    registry_log_category_map = {
        for category in var.registry_diagnostic_log_category_list:
            category => category
    }

    log_analytics_map = var.log_analytics_workspace_id == "" ? {} : {
      machine_learning = {
        resource_id = local.machine_learning_resource_id
        category_map = local.ml_log_category_map
      }
      vault = {
        resource_id = azurerm_key_vault.machine_learning.id
        category_map = local.vault_log_category_map
      }
      registry = {
        resource_id = azurerm_container_registry.machine_learning.id
        category_map = local.registry_log_category_map
      }
    }

    # Needed as dynamic blocks *only* accept maps for for_each
    source_dependent_map = var.secure_dependent_resources ? { one = "one"} : {}

    machine_learning_parms = templatefile("${path.module}/parameters.template.json", {location = var.location, ml_workspace_name = var.machine_learning_workspace_name, resource_group_name = var.resource_group_name, ml_workplace_sku = var.machine_learning_workplace_sku, tags_json = local.tags_json, key_vault_name = var.key_vault_name, key_vault_rg_name = var.resource_group_name, storage_account_name = var.storage_account_name, storage_account_rg_name = var.resource_group_name, container_registry_name = var.container_registry_name, container_registry_rg_name = var.resource_group_name, vnet_name = var.vnet_name, vnet_rg_name = var.vnet_rg_name, subnet_name = var.subnet_name, private_endpoint_name = var.workspace_private_endpoint_name, private_endpoint_rg_name = var.resource_group_name, app_insights_name = var.app_insights_name, app_insights_rg_name = var.resource_group_name})
    machine_learning_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.MachineLearningServices/workspaces/${var.machine_learning_workspace_name}"
    subnet_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.vnet_rg_name}/providers/Microsoft.Network/virtualNetworks/${var.vnet_name}/subnets/${var.subnet_name}"
}

data "azurerm_client_config" "current" {}  

resource "azurerm_key_vault" "machine_learning" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.key_vault_disk_soft_delete_days
  purge_protection_enabled    = var.key_vault_disk_purge_protection
  tags                        = var.tags

  sku_name = var.key_vault_sku

  # Only 0 or 1 entry depending on var.secure_dependent_resources
  dynamic "network_acls" {
    for_each = local.source_dependent_map
    content {
      default_action = "Deny"
      bypass         = "AzureServices"
    }
  }
}

resource "azurerm_private_endpoint" "machine_learning_vault" {
  name                      = "PRIVATELINK-VAULT-${upper(azurerm_key_vault.machine_learning.name)}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  subnet_id                 = local.subnet_id
  tags                      = var.tags
  
  private_service_connection {
      name                           = azurerm_key_vault.machine_learning.name
      private_connection_resource_id = azurerm_key_vault.machine_learning.id
      is_manual_connection           = false
      subresource_names              = ["vault"]
  }
}

resource "azurerm_storage_account" "machine_learning" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name

  location                 = var.location
  account_tier             = var.storage_account_account_tier
  account_replication_type = var.storage_account_account_replication
  tags                     = var.tags
}

resource "azurerm_storage_account_network_rules" "machine_learning_storage" {
  count = var.secure_dependent_resources ? 1 : 0
  resource_group_name  = var.resource_group_name
  storage_account_name = azurerm_storage_account.machine_learning.name

  default_action             = "Deny"
  virtual_network_subnet_ids = [local.subnet_id]
  bypass                     = ["AzureServices"]
}

resource "azurerm_private_endpoint" "machine_learning_storage_blob" {
  name                      = "PRIVATELINK-BLOB-${upper(azurerm_storage_account.machine_learning.name)}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  subnet_id                 = local.subnet_id
  tags                      = var.tags
  
  private_service_connection {
      name                           = azurerm_storage_account.machine_learning.name
      private_connection_resource_id = azurerm_storage_account.machine_learning.id
      is_manual_connection           = false
      subresource_names              = ["blob"]
  }
}

resource "azurerm_private_endpoint" "machine_learning_storage_file" {
  name                      = "PRIVATELINK-FILE-${upper(azurerm_storage_account.machine_learning.name)}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  subnet_id                 = local.subnet_id
  tags                      = var.tags
  
  private_service_connection {
      name                           = azurerm_storage_account.machine_learning.name
      private_connection_resource_id = azurerm_storage_account.machine_learning.id
      is_manual_connection           = false
      subresource_names              = ["file"]
  }
}

resource "azurerm_container_registry" "machine_learning" {
  name                     = var.container_registry_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.container_registry_sku
  georeplication_locations = var.container_registry_geo_locations
  tags                     = var.tags

  # Only 0 or 1 entry depending on var.secure_dependent_resources
  dynamic "network_rule_set" {
    for_each = local.source_dependent_map
    content {
      default_action = "Deny"
      virtual_network {
        action = "Allow"
        subnet_id = local.subnet_id
      }
    }
  }
}

resource "azurerm_private_endpoint" "machine_learning_storage_registry" {
  name                      = "PRIVATELINK-REGISTRY-${upper(azurerm_storage_account.machine_learning.name)}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  subnet_id                 = local.subnet_id
  tags                      = var.tags
  
  private_service_connection {
      name                           = azurerm_container_registry.machine_learning.name
      private_connection_resource_id = azurerm_container_registry.machine_learning.id
      is_manual_connection           = false
      subresource_names              = ["registry"]
  }
}

resource "azurerm_application_insights" "machine_learning" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.app_insights_app_type
  tags                = var.tags
}

resource "azurerm_resource_group_template_deployment" "machine_learning" {
  depends_on          = [azurerm_key_vault.machine_learning
                          , azurerm_storage_account.machine_learning
                          , azurerm_container_registry.machine_learning
                          , azurerm_application_insights.machine_learning
                        ]

  name                = var.deployment_name
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  parameters_content  = local.machine_learning_parms
  template_content    = file("${path.module}/arm_template.json")
  debug_level         = "requestContent, responseContent"
}

resource "azurerm_monitor_diagnostic_setting" "machine_learning_diag" {
  depends_on = [azurerm_resource_group_template_deployment.machine_learning]
  for_each = local.log_analytics_map

  name                            = var.diagnostics_name
  target_resource_id              = each.value["resource_id"]
  log_analytics_workspace_id      = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
      days = var.log_analytics_retention_days
    }
  }

  dynamic "log" {
    for_each = each.value["category_map"]
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
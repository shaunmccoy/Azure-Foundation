resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  tags                     = var.tags

  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = var.shared_access_key_enabled
  default_to_oauth_authentication  = true
  cross_tenant_replication_enabled = false
  public_network_access            = length(var.virtual_network_subnet_ids) > 0 || var.allow_azure_services ? "Enabled" : "Disabled"

  blob_properties {
    versioning_enabled = var.blob_versioning_enabled

    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.blob_delete_retention_days
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = var.allow_azure_services ? ["Logging", "Metrics", "AzureServices"] : ["Logging", "Metrics"]
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }
}

# The static_website block left the storage account resource in azurerm 5.0.
resource "azurerm_storage_account_static_website" "this" {
  count = var.static_website == null ? 0 : 1

  storage_account_id = azurerm_storage_account.this.id
  index_document     = var.static_website.index_document
  error_404_document = var.static_website.error_404_document
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = "PRIVATELINK-${upper(each.key)}-${upper(var.name)}"
  location            = var.location
  resource_group_name = coalesce(var.private_endpoint_resource_group_name, var.resource_group_name)
  subnet_id           = each.value.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-${each.key}"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = [each.key]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_ids) == 0 ? [] : [each.value.private_dns_zone_ids]

    content {
      name                 = "default"
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "audit"
  }

  enabled_metric {
    category = "Transaction"
  }
}

locals {
  web_static_block = [
    {
      index = var.web_index_document
      error = var.error_404_document
    }
  ]
  empty_block = []

  static_block_list = var.web_index_document == "" ? local.empty_block : local.web_static_block
}

data "azurerm_resource_group" "storage" {
  name     = var.resource_group_name
}

resource "azurerm_storage_account" "storage" {
  name                      = var.storage_name
  resource_group_name       = data.azurerm_resource_group.storage.name
  location                  = data.azurerm_resource_group.storage.location
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  allow_blob_public_access  = var.allow_blob_public_access

  blob_properties {
    delete_retention_policy {
      days = 30
    }
  }
  
  network_rules {
    default_action           = "Deny"
    bypass                   = var.allow_azure_services == true ? ["Logging","Metrics","AzureServices"] : ["Logging","Metrics"]
  }

  dynamic "static_website" {
      for_each = local.static_block_list

      content {
            index_document      = static_website.value.index
            error_404_document  = static_website.value.error
      }
  }
  
  tags = var.resource_tags
}

### PRIVATELINK ####

data "azurerm_resource_group" "privatelink" {
  name     = var.privatelink_resource_group_name
}

data "azurerm_subnet" "privatelink" {
  name                 = "PrivateLink"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

resource "azurerm_private_endpoint" "storage" {
  name                      = "PRIVATELINK-${upper(var.storage_usage)}-${upper(azurerm_storage_account.storage.name)}"
  resource_group_name       = data.azurerm_resource_group.privatelink.name
  location                  = data.azurerm_resource_group.privatelink.location
  subnet_id                 = data.azurerm_subnet.privatelink.id
 
  private_service_connection {
      name                           = azurerm_storage_account.storage.name
      private_connection_resource_id = azurerm_storage_account.storage.id
      is_manual_connection           = false
      subresource_names              = [var.storage_usage]
  }
}

### END PRIVATELINK ####


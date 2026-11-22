locals {
  common_tags = {
    Owner = "Test"
  }
}

#resource "azurerm_private_dns_zone" "web" {
#  name                 = "privatelink.web.core.windows.net"
#  resource_group_name  = var.resource_group_name
#}

resource "azurerm_private_dns_a_record" "web_site_storage" {
  name                = lower(module.storage_account_privatelink_test.storage_account_name)
  zone_name           = "privatelink.web.core.windows.net"
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [module.storage_account_privatelink_test.storage_account_private_ip]
}

module "storage_account_privatelink_test" {
  source                          = "../../modules/storage_account_privatelink"
  resource_tags                   = local.common_tags
  resource_group_name             = var.resource_group_name
  storage_name                    = "examplelabtestweb"
  storage_usage                   = "web"
  account_replication_type        = "RAGRS"
  account_tier                    = "Standard"
  privatelink_resource_group_name = var.resource_group_name
  vnet_resource_group_name        = var.resource_group_name
  vnet_name                       = var.vnet_name  
  log_analytics_workspace_id      = var.log_analytics_workspace_id

  web_index_document              = "index.html"
  error_404_document              = "404index.html"
}

resource "azurerm_storage_container" "website_container" {
  name                  = "$web"
  storage_account_name  = module.storage_account_privatelink_test.storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = module.storage_account_privatelink_test.storage_account_name
  storage_container_name = azurerm_storage_container.website_container.name
  type                   = "Block"
  content_type           = "text/html"
  source                 = "html/index.html"
}

resource "azurerm_storage_blob" "index404" {
  name                   = "404index.html"
  storage_account_name   = module.storage_account_privatelink_test.storage_account_name
  storage_container_name = azurerm_storage_container.website_container.name
  type                   = "Block"
  content_type           = "text/html"
  source                 = "html/404index.html"
}
### CONTAINER REGISTRY ###

resource "azurerm_container_registry" "this" {
  name                = "${local.loc_code}HUB${local.env_code}ACR"
  resource_group_name = azurerm_resource_group.this["ACR"].name
  location            = var.location
  sku                 = var.acr_sku
  tags                = local.common_tags

  # Pull and push with Entra ID identities (AcrPull / AcrPush); no shared admin account.
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false
  zone_redundancy_enabled       = var.acr_sku == "Premium" && length(var.zones) > 0

  dynamic "georeplications" {
    for_each = var.acr_sku == "Premium" ? var.acr_georeplication_locations : []

    content {
      location                        = georeplications.value
      global_endpoint_routing_enabled = true
      zone_redundancy_enabled         = true
      tags                            = local.common_tags
    }
  }
}

resource "azurerm_private_endpoint" "acr" {
  name                = "PRIVATELINK-ACR-${upper(azurerm_container_registry.this.name)}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this["PRIVATELINK"].name
  subnet_id           = module.vnet.subnet_ids["PrivateLink"]
  tags                = local.common_tags

  private_service_connection {
    name                           = azurerm_container_registry.this.name
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.central_dns_zone_ids["privatelink.azurecr.io"]]
  }
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = module.devops_identity.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = module.log_analytics.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

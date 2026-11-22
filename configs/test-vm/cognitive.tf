### OPTIONAL PRIVATE-LINK TEST TARGET ###

data "azurerm_subnet" "private_endpoint" {
  count = var.cognitive_service == null ? 0 : 1

  name                 = var.cognitive_service.private_endpoint_subnet_name
  virtual_network_name = var.cognitive_service.vnet_name
  resource_group_name  = var.cognitive_service.vnet_resource_group_name
}

resource "azurerm_cognitive_account" "test" {
  count = var.cognitive_service == null ? 0 : 1

  name                = lower("${local.name_prefix}-cogservice")
  location            = azurerm_resource_group.testers.location
  resource_group_name = azurerm_resource_group.testers.name
  kind                = var.cognitive_service.kind
  sku_name            = var.cognitive_service.sku_name
  tags                = local.common_tags

  # The custom subdomain is what private endpoints resolve; it cannot be changed later.
  custom_subdomain_name         = lower("${local.name_prefix}-cogservice")
  public_network_access_enabled = false
  local_auth_enabled            = false

  network_acls {
    default_action = "Deny"
  }
}

resource "azurerm_private_endpoint" "cognitive" {
  count = var.cognitive_service == null ? 0 : 1

  name                = "${azurerm_cognitive_account.test[0].name}-PE"
  location            = azurerm_resource_group.testers.location
  resource_group_name = azurerm_resource_group.testers.name
  subnet_id           = data.azurerm_subnet.private_endpoint[0].id
  tags                = local.common_tags

  private_service_connection {
    name                           = azurerm_cognitive_account.test[0].name
    private_connection_resource_id = azurerm_cognitive_account.test[0].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.cognitive_service.private_dns_zone_ids) == 0 ? [] : [1]

    content {
      name                 = "default"
      private_dns_zone_ids = var.cognitive_service.private_dns_zone_ids
    }
  }
}

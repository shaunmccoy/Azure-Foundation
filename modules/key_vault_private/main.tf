resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name
  tags                = var.tags

  # Azure RBAC replaces vault access policies; purge protection is irreversible by design.
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = var.soft_delete_retention_days

  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = false

  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_private_endpoint" "this" {
  name                = "PRIVATELINK-KV-${upper(var.name)}"
  location            = var.location
  resource_group_name = coalesce(var.private_endpoint_resource_group_name, var.resource_group_name)
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = var.name
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  # Registers the A record in the central zone; no hand-written DNS records.
  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) == 0 ? [] : [var.private_dns_zone_ids]

    content {
      name                 = "default"
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "audit"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

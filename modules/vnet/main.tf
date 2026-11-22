resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id == null ? [] : [var.ddos_protection_plan_id]

    content {
      id     = ddos_protection_plan.value
      enable = true
    }
  }
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                              = each.key
  resource_group_name               = azurerm_virtual_network.this.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = each.value.address_prefixes
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
  default_outbound_access_enabled   = each.value.default_outbound_access_enabled

  dynamic "service_endpoint" {
    for_each = toset(each.value.service_endpoints)

    content {
      service = service_endpoint.value
    }
  }

  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]

    content {
      name = "delegation"

      service_delegation {
        name    = delegation.value
        actions = each.value.delegation_actions
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_virtual_network.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

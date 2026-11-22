locals {
    log_category_map = {
          for category in var.diagnostic_log_category_list:
              category => category
    }
}

resource "azurerm_lb" "load_balancer" {
  name                  = var.load_balancer_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  sku                   = "Standard" 
  tags                  = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_config
    content {
      name                            = frontend_ip_configuration.key
      subnet_id                       = frontend_ip_configuration.value["subnet_id"]
      private_ip_address              = frontend_ip_configuration.value["private_ip_address"]
      private_ip_address_allocation   = frontend_ip_configuration.value["private_ip_address"] != "" ? "Static" : "Dynamic"
    }
  }
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
  count           = length(var.backend_address_pool_list)
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = var.backend_address_pool_list[count.index]
}

resource "azurerm_lb_nat_pool" "nat_pool" {
  for_each                       = var.nat_pool_config

  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = each.key
  protocol                       = each.value["protocol"]
  frontend_port_start            = each.value["frontend_port_start"]
  frontend_port_end              = each.value["frontend_port_end"]
  backend_port                   = each.value["backend_port"]
  frontend_ip_configuration_name = each.value["frontend_ip_configuration_name"]
}

resource "azurerm_lb_nat_rule" "nat_rule" {
  for_each                       = var.nat_rule_config

  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = each.key
  protocol                       = each.value["protocol"]
  frontend_port                  = each.value["frontend_port"]
  backend_port                   = each.value["backend_port"]
  frontend_ip_configuration_name = each.value["frontend_ip_configuration_name"]
}

resource "azurerm_lb_probe" "probe" {
  for_each                       = var.probe_config

  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = each.key
  port                           = each.value["port"]
  protocol                       = each.value["protocol"]
  request_path                   = each.value["request_path"]
}

resource "azurerm_lb_rule" "lb_rule" {
  for_each                       = var.lb_rule_config

  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = each.key
  protocol                       = each.value["protocol"]
  frontend_port                  = each.value["frontend_port"]
  backend_port                   = each.value["backend_port"]
  frontend_ip_configuration_name = each.value["frontend_ip_configuration_name"]
  backend_address_pool_id        = try(local.backend_pool_name_id_map[each.value["backend_address_pool_name"]], "")
  probe_id                       = try(local.probe_name_id_map[each.value["probe_name"]], "")
}

resource "azurerm_monitor_diagnostic_setting" "load_balancer_diag" {
  name                            = var.diagnostics_name
  depends_on                      = [ azurerm_lb.load_balancer ]
  count                           = var.log_analytics_workspace_id == "" ? 0 : 1

  target_resource_id              = azurerm_lb.load_balancer.id
  log_analytics_workspace_id      = var.log_analytics_workspace_id

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
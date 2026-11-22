locals {
  default_rules = {
    "${var.rule_name_prefix}-Incoming-Allow-TCP-22" = {
      priority    = 1001, access = "Allow", protocol = "Tcp", port = "22", source = "VirtualNetwork", destination = "VirtualNetwork"
      description = "Allow SSH from the virtual network"
    }
    "${var.rule_name_prefix}-Incoming-Allow-TCP-3389" = {
      priority    = 1002, access = "Allow", protocol = "Tcp", port = "3389", source = "VirtualNetwork", destination = "VirtualNetwork"
      description = "Allow RDP from the virtual network"
    }
    "${var.rule_name_prefix}-Incoming-Allow-ICMP" = {
      priority    = 1003, access = "Allow", protocol = "Icmp", port = "*", source = "VirtualNetwork", destination = "VirtualNetwork"
      description = "Allow ICMP from the virtual network"
    }
    "${var.rule_name_prefix}-Deny-Incoming-CatchAll" = {
      priority    = 4096, access = "Deny", protocol = "*", port = "*", source = "*", destination = "*"
      description = "Deny all other inbound traffic"
    }
  }
}

resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "default" {
  for_each = var.default_rules_enabled ? local.default_rules : {}

  name                        = each.key
  description                 = "Managed by Terraform - ${each.value.description}"
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = each.value.port
  source_address_prefix       = each.value.source
  destination_address_prefix  = each.value.destination
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_network_security_group.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}

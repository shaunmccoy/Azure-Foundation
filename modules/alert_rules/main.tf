locals {
  # CIS Microsoft Azure Foundations Benchmark, "Activity Log Alerts" section.
  activity_log_alerts = {
    "CIS - Create Policy Assignment" = {
      operation   = "Microsoft.Authorization/policyAssignments/write"
      category    = "Administrative"
      description = "CIS Benchmark - alert on creation of policy assignments"
    }
    "CIS - Delete Policy Assignment" = {
      operation   = "Microsoft.Authorization/policyAssignments/delete"
      category    = "Administrative"
      description = "CIS Benchmark - alert on deletion of policy assignments"
    }
    "CIS - Create or Update Network Security Group" = {
      operation   = "Microsoft.Network/networkSecurityGroups/write"
      category    = "Administrative"
      description = "CIS Benchmark - alert on creation or update of network security groups"
    }
    "CIS - Delete Network Security Group" = {
      operation   = "Microsoft.Network/networkSecurityGroups/delete"
      category    = "Administrative"
      description = "CIS Benchmark - alert on deletion of network security groups"
    }
    "CIS - Create or Update Network Security Group Rules" = {
      operation   = "Microsoft.Network/networkSecurityGroups/securityRules/write"
      category    = "Administrative"
      description = "CIS Benchmark - alert on creation or update of network security group rules"
    }
    "CIS - Delete Network Security Group Rules" = {
      operation   = "Microsoft.Network/networkSecurityGroups/securityRules/delete"
      category    = "Administrative"
      description = "CIS Benchmark - alert on deletion of network security group rules"
    }
    "CIS - Create or Update Security Solution" = {
      operation   = "Microsoft.Security/securitySolutions/write"
      category    = "Administrative"
      description = "CIS Benchmark - alert on creation or update of security solutions"
    }
    "CIS - Delete Security Solution" = {
      operation   = "Microsoft.Security/securitySolutions/delete"
      category    = "Administrative"
      description = "CIS Benchmark - alert on deletion of security solutions"
    }
    "CIS - Create or Update Public IP Address" = {
      operation   = "Microsoft.Network/publicIPAddresses/write"
      category    = "Administrative"
      description = "CIS Benchmark - alert on creation or update of public IP addresses"
    }
    "CIS - Delete Public IP Address" = {
      operation   = "Microsoft.Network/publicIPAddresses/delete"
      category    = "Administrative"
      description = "CIS Benchmark - alert on deletion of public IP addresses"
    }
    "${var.policy_alert_prefix} - Policy Audit Violations" = {
      operation   = "Microsoft.Authorization/policies/audit/action"
      category    = "Policy"
      description = "Organisation policy - audit violations"
    }
  }
}

resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.action_group_name, " ", ""), 0, 12)
  tags                = var.tags

  email_receiver {
    name                    = trimspace(var.action_group_name)
    email_address           = var.email_address
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_activity_log_alert" "this" {
  for_each = local.activity_log_alerts

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = each.value.description
  tags                = var.tags

  criteria {
    operation_name = each.value.operation
    category       = each.value.category
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

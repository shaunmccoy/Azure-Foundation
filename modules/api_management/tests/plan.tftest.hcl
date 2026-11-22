# Offline tests: no Azure credentials needed. Run with `terraform test`.
mock_provider "azurerm" {
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/apim-identity"
      principal_id = "00000000-0000-0000-0000-0000000000aa"
      client_id    = "00000000-0000-0000-0000-0000000000ab"
    }
  }

  mock_resource "azurerm_api_management" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.ApiManagement/service/example-apim"
    }
  }

  mock_resource "azurerm_application_insights" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.Insights/components/example-appinsights"
    }
  }

  mock_resource "azurerm_api_management_logger" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.ApiManagement/service/example-apim/loggers/applicationinsights"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/example-nsg"
    }
  }

  mock_resource "azurerm_public_ip" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/example-pip"
    }
  }
}

variables {
  name                       = "example-apim"
  resource_group_name        = "rg"
  location                   = "centralus"
  publisher_name             = "Example"
  publisher_email            = "api-platform@example.com"
  subnet_id                  = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-cus/subnets/APIManagement"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/logs"

  additional_locations = {
    eastus2 = {
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-eu2/subnets/APIManagement"
    }
  }
}

run "multi_region_internal" {
  command = plan

  assert {
    condition     = azurerm_api_management.this.sku_name == "Premium_3" && azurerm_api_management.this.virtual_network_type == "Internal"
    error_message = "Defaults should be Premium, three units, internal mode."
  }

  assert {
    condition     = length(azurerm_network_security_group.this) == 2 && length(azurerm_subnet_network_security_group_association.this) == 2
    error_message = "Each region should get its own NSG, attached to its subnet."
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 0
    error_message = "No customer-owned public IP is needed in internal mode."
  }

  assert {
    condition     = length(azurerm_management_lock.this) == 1
    error_message = "The delete lock should be on by default."
  }
}

run "external_mode_with_own_public_ips" {
  command = plan

  variables {
    virtual_network_type = "External"
    public_ip_enabled    = true
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 2
    error_message = "One public IP per region when public_ip_enabled is set."
  }

  assert {
    condition     = contains(keys(azurerm_network_security_rule.this), "centralus/Allow-Internet-Inbound")
    error_message = "External mode must allow client traffic from the Internet."
  }
}

run "rejects_gateway_disable_in_internal_mode" {
  command = plan

  variables {
    primary_gateway_disabled = true
  }

  expect_failures = [var.primary_gateway_disabled]
}

run "rejects_units_that_do_not_spread_across_zones" {
  command = plan

  variables {
    capacity = 4
  }

  expect_failures = [var.zones]
}

run "rejects_multi_region_on_developer_tier" {
  command = plan

  variables {
    sku_tier = "Developer"
    capacity = 1
    zones    = []
  }

  expect_failures = [var.additional_locations]
}

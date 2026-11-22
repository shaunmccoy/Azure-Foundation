# Offline tests: no Azure credentials needed. scripts/validate.sh runs them once per environment file.
mock_provider "azurerm" {
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/CUS-API-P-APIM-RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/apim-identity"
      principal_id = "00000000-0000-0000-0000-0000000000aa"
      client_id    = "00000000-0000-0000-0000-0000000000ab"
    }
  }

  mock_resource "azurerm_api_management" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/CUS-API-P-APIM-RG/providers/Microsoft.ApiManagement/service/org-cus-api-p-apim"
    }
  }

  mock_resource "azurerm_application_insights" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/CUS-API-P-APIM-RG/providers/Microsoft.Insights/components/apim-appinsights"
    }
  }

  mock_resource "azurerm_api_management_logger" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/CUS-API-P-APIM-RG/providers/Microsoft.ApiManagement/service/org-cus-api-p-apim/loggers/applicationinsights"
    }
  }

  mock_resource "azurerm_public_ip" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/CUS-API-P-APIM-RG/providers/Microsoft.Network/publicIPAddresses/apim-pip"
    }
  }

  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/CUS-API-P-APIM-RG/providers/Microsoft.Network/networkSecurityGroups/apim-nsg"
    }
  }
}

run "plans_with_environment_file" {
  command = plan

  assert {
    condition     = length(azurerm_private_dns_a_record.gateway) == 1 + length(var.additional_regions)
    error_message = "There should be one private DNS record per gateway region."
  }

  assert {
    condition     = var.env != "PROD" || (var.sku_tier == "Premium" && length(var.zones) == 3 && length(var.additional_regions) >= 1)
    error_message = "Production must be Premium, zone-redundant and multi-region."
  }
}

run "rejects_multi_region_on_developer_tier" {
  command = plan

  variables {
    sku_tier = "Developer"
    capacity = 1
    zones    = []
    additional_regions = {
      eastus2 = {
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000201/resourceGroups/EU2-API-R-NET-RG/providers/Microsoft.Network/virtualNetworks/EU2-API-R-VNET/subnets/APIManagement"
      }
    }
  }

  expect_failures = [var.additional_regions]
}

run "rejects_units_that_do_not_spread_across_zones" {
  command = plan

  variables {
    sku_tier = "Premium"
    capacity = 2
    zones    = ["1", "2", "3"]
  }

  expect_failures = [var.capacity]
}

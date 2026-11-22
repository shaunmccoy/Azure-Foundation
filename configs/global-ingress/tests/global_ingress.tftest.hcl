# Offline tests: no Azure credentials needed. scripts/validate.sh runs them once per environment file.
mock_provider "azurerm" {
  mock_resource "azurerm_traffic_manager_profile" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-GLOBAL-INGRESS-RG/providers/Microsoft.Network/trafficManagerProfiles/CUS-HUB-P-TRAFFIC-MANAGER"
    }
  }
}

run "plans_with_environment_file" {
  command = plan

  assert {
    condition     = length(azurerm_traffic_manager_azure_endpoint.this) == length(var.endpoints)
    error_message = "Every regional gateway should be an endpoint."
  }
}

run "rejects_single_region" {
  command = plan

  variables {
    endpoints = {
      centralus = {
        public_ip_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/CUS-HUB-P-APP-GATEWAY-RG/providers/Microsoft.Network/publicIPAddresses/CUS-HUB-P-APP-GATEWAY-PUBLIC-IP"
        priority     = 1
      }
    }
  }

  expect_failures = [var.endpoints]
}

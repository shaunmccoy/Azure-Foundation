# Offline tests: run with `terraform test` (no Azure credentials needed).
mock_provider "azurerm" {}

variables {
  subscription_id     = "11111111-1111-1111-1111-111111111111"
  hub_subscription_id = "22222222-2222-2222-2222-222222222222"
  location            = "eastus2"
  env                 = "prod"
  tla                 = "ABC"
  business_unit       = "FIN"
  cost_center         = "12345"
}

run "naming_and_tags" {
  command = plan

  assert {
    condition     = output.prefix == "EUS2-FIN-PRD"
    error_message = "Unexpected prefix: ${output.prefix}"
  }

  assert {
    condition     = output.hub_prefix == "EUS2-HUB-PRD"
    error_message = "Unexpected hub_prefix: ${output.hub_prefix}"
  }

  assert {
    condition     = output.log_analytics_workspace_id == "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/EUS2-HUB-PRD-logs-rg/providers/Microsoft.OperationalInsights/workspaces/EUS2-HUB-PRD-azloganalytics"
    error_message = "Unexpected workspace ID: ${output.log_analytics_workspace_id}"
  }

  assert {
    condition     = output.common_tags["sm:tla"] == "abc" && output.common_tags["sm:datacenter"] == "eastus2"
    error_message = "Tags are not normalised to lower case."
  }
}

run "rejects_unknown_location" {
  command = plan

  variables {
    location = "mars"
  }

  expect_failures = [var.location]
}

run "rejects_unknown_env" {
  command = plan

  variables {
    env = "qa"
  }

  expect_failures = [var.env]
}

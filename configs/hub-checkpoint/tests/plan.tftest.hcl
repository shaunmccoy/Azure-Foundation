# Offline tests: run with `terraform test` (no Azure credentials needed).
mock_provider "azurerm" {}

variables {
  hub_subscription_id = "00000000-0000-0000-0000-000000000001"
  subscription_id     = "00000000-0000-0000-0000-000000000001"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  env                 = "PROD"
  business_unit       = "INFR"
  cost_center         = "0000"
  location            = "centralus"
  tla                 = "HUB"
}

run "resource_group" {
  command = plan

  assert {
    condition     = output.resource_group_name == "CUS-HUB-P-CHECKPOINT-RG"
    error_message = "Unexpected resource group name."
  }

  assert {
    condition     = azurerm_resource_group.checkpoint.tags["org:resourceClass"] == "firewall"
    error_message = "Unexpected resourceClass tag."
  }
}

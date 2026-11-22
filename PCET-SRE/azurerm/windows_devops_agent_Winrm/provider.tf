provider "azurerm" {
  version = "=2.0.0"
  features{}
}

provider "azurerm" {
  alias  = "image"
  subscription_id = "55555555-5555-5555-5555-555555555555"
  tenant_id = "00000000-0000-0000-0000-000000000000"
  version = "=2.0.0"
  features{}
}

provider "azurerm" {
  alias  = "key"
  subscription_id = "10000000-0000-0000-0000-000000000005"
  tenant_id = "00000000-0000-0000-0000-000000000000"
  version = "=2.0.0"
  features{}
}

terraform {
    required_version = ">= 0.12"
    }
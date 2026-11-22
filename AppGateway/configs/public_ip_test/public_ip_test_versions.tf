terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = "~>2.0"
  }
   backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
  subscription_id   = var.subscription_id
  tenant_id         = var.tenant_id
}
terraform {
  required_version = ">= 0.14"
  required_providers {
    azurerm = "~>2.46"
  }
   backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
  subscription_id   = var.subscription_id
  tenant_id         = var.tenant_id
}
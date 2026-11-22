terraform {
  # Provider-defined functions, cross-variable validation and the current
  # azurerm 5.x provider protocol all require a modern Terraform release.
  required_version = ">= 1.14.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.14"
    }
  }
}

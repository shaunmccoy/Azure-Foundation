terraform {
  required_version = ">= 1.14.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.14"
    }
  }

  # Supplied at init time: -backend-config=environments/<name>.backend.hcl or individual -backend-config flags.
  backend "azurerm" {}
}

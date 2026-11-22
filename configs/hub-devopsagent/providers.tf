provider "azurerm" {
  subscription_id     = var.subscription_id
  storage_use_azuread = true

  features {}
}

# Subscription that hosts the compute gallery with the agent image.
provider "azurerm" {
  alias               = "img"
  subscription_id     = var.img_subscription_id
  storage_use_azuread = true

  features {}
}

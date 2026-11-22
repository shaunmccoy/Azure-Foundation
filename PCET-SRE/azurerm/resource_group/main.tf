locals {

  location       = var.location
  region         = var.region[var.location]
  env            = var.env_code[var.env]
  tla            = var.tla
  bu             = var.business_unit
  prefix         = "${local.bu}-${local.region}-${local.tla}-${local.env}-"
}

resource "azurerm_resource_group" "RG" {
  name     ="${local.prefix}${var.RG-Count}"
  location = var.location
  tags     = var.tags
}

output "id" {
  value = azurerm_resource_group.RG.id
}

output "name" {
  value = azurerm_resource_group.RG.name
}
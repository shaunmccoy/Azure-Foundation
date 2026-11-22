locals {
  # Common tags to be assigned to all resources
  common_tags = {
    TLA          = var.tla
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
  }
}

resource "azurerm_resource_group" "RG" {
  name     =var.resource_group_name
  location = var.location

  tags = {
    TLA          = var.tla
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
  }
}
resource "azurerm_app_service_plan" "plan" {
  name                = var.ase_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_environment_id = var.app_service_environment_id
  tags = var.tags
  kind = var.app_kind
  reserved = var.reserved
  sku {
    tier = var.plan_tier
    size = var.plan_size
    capacity = 1
  }

  timeouts {
    create = "2h"
    update = "2h"
  }

}
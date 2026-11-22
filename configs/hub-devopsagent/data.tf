### LOOKUPS (created by hub-base) ###

data "azurerm_subnet" "devops_agents" {
  name                 = "DevOpsAgents"
  virtual_network_name = local.hub_names.vnet
  resource_group_name  = local.hub_names.network_resource_group
}

data "azurerm_user_assigned_identity" "devops" {
  name                = local.hub_names.devops_identity
  resource_group_name = local.hub_names.identity_resource_group
}

data "azurerm_key_vault" "infra" {
  name                = local.hub_names.infra_keyvault
  resource_group_name = local.hub_names.keyvault_resource_group
}

data "azurerm_route_table" "devops" {
  name                = local.hub_names.devops_route_table
  resource_group_name = local.hub_names.network_resource_group
}

data "azurerm_shared_image" "agent" {
  count    = var.scaleset_enabled ? 1 : 0
  provider = azurerm.img

  name                = var.img_name
  gallery_name        = var.img_gallery_name
  resource_group_name = var.img_resource_group_name
}

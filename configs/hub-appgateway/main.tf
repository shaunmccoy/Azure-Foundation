# Regional ingress: zone-redundant Application Gateway (WAF v2) in the hub's AppGateway subnet.
# Deploy once per region; configs/global-ingress spreads traffic across the regional gateways.

data "azurerm_subnet" "app_gateway" {
  name                 = var.subnet_name
  virtual_network_name = local.hub_names.vnet
  resource_group_name  = local.hub_names.network_resource_group
}

data "azurerm_key_vault" "infra" {
  name                = local.hub_names.infra_keyvault
  resource_group_name = local.hub_names.keyvault_resource_group
}

resource "azurerm_resource_group" "app_gateway" {
  name     = "${local.prefix}-APP-GATEWAY-RG"
  location = var.location
  tags     = local.common_tags
}

module "public_ip" {
  source = "../../modules/public_ip"

  name                       = "${local.prefix}-APP-GATEWAY-PUBLIC-IP"
  resource_group_name        = azurerm_resource_group.app_gateway.name
  location                   = var.location
  zones                      = var.zones
  domain_name_label          = lower("${var.org_code}-${local.prefix}-appgw")
  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.common_tags
}

# The gateway reads its TLS certificates from Key Vault with this identity.
module "identity" {
  source = "../../modules/managed_identity"

  name                = "${local.prefix}-IDENTITY-APPGATEWAY"
  resource_group_name = azurerm_resource_group.app_gateway.name
  location            = var.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "key_vault_secrets" {
  scope                = data.azurerm_key_vault.infra.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.identity.principal_id
  principal_type       = "ServicePrincipal"
}

module "application_gateway" {
  source = "../../modules/application_gateway"

  name                 = "${local.prefix}-APP-GATEWAY"
  resource_group_name  = azurerm_resource_group.app_gateway.name
  location             = var.location
  zones                = var.zones
  subnet_id            = data.azurerm_subnet.app_gateway.id
  public_ip_address_id = module.public_ip.id
  identity_ids         = [module.identity.id]

  waf_mode     = var.waf_mode
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity

  ssl_certificates          = var.ssl_certificates
  trusted_root_certificates = var.trusted_root_certificates
  listeners                 = var.listeners
  backend_pools             = var.backend_pools
  backend_settings          = var.backend_settings
  probes                    = var.probes
  routing_rules             = var.routing_rules

  log_analytics_workspace_id = local.log_analytics_workspace_id
  tags                       = local.common_tags

  depends_on = [azurerm_role_assignment.key_vault_secrets]
}

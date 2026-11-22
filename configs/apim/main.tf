# API Management: one service, zone-redundant in the primary region, with a gateway in each
# additional region. Internal VNet mode: clients arrive through the regional Application
# Gateways (configs/hub-appgateway), which configs/global-ingress balances across regions.
#
#   client -> Traffic Manager -> regional Application Gateway (WAF) -> regional APIM gateway -> backends
#
# The management plane, developer portal and configuration store live in the primary region
# only. If it is lost, the other regions keep serving traffic with the last known configuration.

resource "azurerm_resource_group" "apim" {
  name     = "${local.prefix}-APIM-RG"
  location = var.location
  tags     = local.common_tags
}

module "api_management" {
  source = "../../modules/api_management"

  name                = local.apim_name
  resource_group_name = azurerm_resource_group.apim.name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_tier = var.sku_tier
  capacity = var.capacity
  zones    = var.zones

  virtual_network_type     = var.virtual_network_type
  subnet_id                = var.apim_subnet_id
  additional_locations     = var.additional_regions
  primary_gateway_disabled = var.primary_gateway_disabled
  client_address_prefix    = var.client_address_prefix

  key_vault_ids                  = var.key_vault_ids
  gateway_custom_domains         = var.gateway_custom_domains
  developer_portal_custom_domain = var.developer_portal_custom_domain
  management_custom_domain       = var.management_custom_domain
  named_values                   = var.named_values

  log_analytics_workspace_id               = local.log_analytics_workspace_id
  application_insights_sampling_percentage = var.application_insights_sampling_percentage
  alerts                                   = var.alert_action_group_id == null ? null : { action_group_id = var.alert_action_group_id }
  delete_lock_enabled                      = var.delete_lock_enabled

  tags = local.common_tags
}

# Internal mode has no public DNS for the gateway: publish each region's private IP so the
# Application Gateway in that region can reach its local gateway.
resource "azurerm_private_dns_a_record" "gateway" {
  for_each = var.private_dns_records == null ? [] : local.gateway_regions

  name                = "${var.private_dns_records.record_prefix}-${lower(var.loc_code[each.value])}"
  private_dns_zone_id = var.private_dns_records.zone_id
  ttl                 = var.private_dns_records.ttl
  records             = module.api_management.private_ip_addresses[each.value]
  tags                = local.common_tags
}

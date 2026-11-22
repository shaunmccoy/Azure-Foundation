locals {
  prefix         = "${local.loc_code}-${upper(var.business_unit)}-${local.env_code}"
  subnet_type    = "private"
  resource_class = "paas"

  # Globally unique: becomes <name>.azure-api.net.
  apim_name = lower("${var.org_code}-${local.prefix}-apim")

  # Every region the gateway runs in, for per-region DNS records.
  gateway_regions = toset(concat([var.location], keys(var.additional_regions)))
}

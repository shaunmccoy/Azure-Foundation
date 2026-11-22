locals {
  prefix         = local.hub_prefix
  subnet_type    = "private"
  resource_class = "test"

  name_prefix = "${local.loc_code}-${var.env}"
}

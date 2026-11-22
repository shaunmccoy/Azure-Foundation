locals {
  prefix         = local.hub_prefix
  subnet_type    = "private"
  resource_class = "agent"

  vm_name_prefix = upper("${local.loc_code}${var.tla}${local.env_code}")
  vmss_name      = upper("${local.loc_code}${var.business_unit}${local.env_code}")

  agent_tags = merge(local.common_tags, { "${var.org_code}:operatingSystem" = "linux" })

  # Everything the DevOps route table sends somewhere explicit bypasses the proxy.
  no_proxy = join(",", data.azurerm_route_table.devops.route[*].address_prefix)
}

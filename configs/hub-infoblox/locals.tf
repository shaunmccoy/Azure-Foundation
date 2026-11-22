locals {
  prefix         = local.hub_prefix
  subnet_type    = "private"
  resource_class = "dns"

  # e.g. CUSHUBPINFOBLOX01
  vm_name_prefix = "${replace(local.prefix, "-", "")}INFOBLOX"

  appliances = {
    for i, vm in var.infoblox_vms : format("%02d", i + 1) => merge(vm, {
      name = "${local.vm_name_prefix}${format("%02d", i + 1)}"
    })
  }

  # Grid traffic (OpenVPN 1194, grid key exchange 2114) is only opened to the
  # existing grid members, and only when some are listed.
  grid_rules = {
    "UDP-1194-Inbound-INFOBLOX" = { priority = 2003, protocol = "Udp", port = "1194", sources = var.grid_member_addresses }
    "UDP-2114-Inbound-INFOBLOX" = { priority = 2004, protocol = "Udp", port = "2114", sources = var.grid_member_addresses }
  }

  vnet_rules = {
    "TCP-53-Inbound-INFOBLOX"  = { priority = 2001, protocol = "Tcp", port = "53", sources = [] }
    "UDP-53-Inbound-INFOBLOX"  = { priority = 2002, protocol = "Udp", port = "53", sources = [] }
    "UDP-161-Inbound-INFOBLOX" = { priority = 2005, protocol = "Udp", port = "161", sources = [] }
    "HTTPS-Inbound-INFOBLOX"   = { priority = 2006, protocol = "Tcp", port = "443", sources = [] }
  }

  # An empty sources list means "from the virtual network".
  infoblox_rules = merge(
    local.vnet_rules,
    { for name, rule in local.grid_rules : name => rule if length(var.grid_member_addresses) > 0 },
  )
}

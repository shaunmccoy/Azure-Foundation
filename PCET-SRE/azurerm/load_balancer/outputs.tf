locals {
  backend_pool_name_id_map = {
    for i, pool_name in var.backend_address_pool_list:
      pool_name => azurerm_lb_backend_address_pool.backend_address_pool[i].id
  }
  nat_pool_name_id_map = {
    for pool in azurerm_lb_nat_pool.nat_pool:
      pool.name => pool.id
  }
  nat_rule_name_id_map = {
    for rule in azurerm_lb_nat_rule.nat_rule:
      rule.name => rule.id
  }
  probe_name_id_map = {
    for probe in azurerm_lb_probe.probe:
      probe.name => probe.id
  }
  lb_rule_name_id_map = {
    for lb_rule in azurerm_lb_rule.lb_rule:
      lb_rule.name => lb_rule.id
  }
}

output load_balancer_resource_id {
  value = azurerm_lb.load_balancer.id
}

output load_balancer_backend_pool_name_id_map {
  value = local.backend_pool_name_id_map
}

output nat_pool_name_id_map {
  value = local.nat_pool_name_id_map
}

output nat_rule_name_id_map {
  value = local.nat_rule_name_id_map
}

output probe_name_id_map {
  value = local.probe_name_id_map
}

output lb_rule_name_id_map {
  value = local.lb_rule_name_id_map
}

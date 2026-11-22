output data_factory_name {
  value = var.data_factory_name
}

output data_factory_resource_id {
  value = local.data_factory_resource_id
}

output private_endpoint_resource_id {
  value = azurerm_private_endpoint.data_factory.id
}

output private_endpoint_fqdn {
  value = azurerm_private_endpoint.data_factory.custom_dns_configs[0].fqdn
}

output private_endpoint_ip_addresses {
  value = azurerm_private_endpoint.data_factory.custom_dns_configs[0].ip_addresses
}

output data_factory_arm_resource_id {
  value = azurerm_resource_group_template_deployment.data_factory.id
}
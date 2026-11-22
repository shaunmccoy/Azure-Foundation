output private_endpoint_storage_file_resource_id {
  value = azurerm_private_endpoint.machine_learning_storage_file.id
}

output private_endpoint_storage_file_fqdn {
  value = azurerm_private_endpoint.machine_learning_storage_file.custom_dns_configs[0].fqdn
}

output private_endpoint_storage_file_ip_addresses {
  value = azurerm_private_endpoint.machine_learning_storage_file.custom_dns_configs[0].ip_addresses
}

output private_endpoint_storage_blob_resource_id {
  value = azurerm_private_endpoint.machine_learning_storage_blob.id
}

output private_endpoint_storage_blob_fqdn {
  value = azurerm_private_endpoint.machine_learning_storage_blob.custom_dns_configs[0].fqdn
}

output private_endpoint_storage_blob_ip_addresses {
  value = azurerm_private_endpoint.machine_learning_storage_blob.custom_dns_configs[0].ip_addresses
}

output private_endpoint_vault_resource_id {
  value = azurerm_private_endpoint.machine_learning_vault.id
}

output private_endpoint_vault_fqdn {
  value = azurerm_private_endpoint.machine_learning_vault.custom_dns_configs[0].fqdn
}

output private_endpoint_vault_ip_addresses {
  value = azurerm_private_endpoint.machine_learning_vault.custom_dns_configs[0].ip_addresses
}

output private_endpoint_registry_resource_id {
  value = azurerm_private_endpoint.machine_learning_storage_registry.id
}

output private_endpoint_registry_fqdn {
  value = azurerm_private_endpoint.machine_learning_storage_registry.custom_dns_configs[0].fqdn
}

output private_endpoint_registry_ip_addresses {
  value = azurerm_private_endpoint.machine_learning_storage_registry.custom_dns_configs[0].ip_addresses
}


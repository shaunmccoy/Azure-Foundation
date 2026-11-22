output automation_account_resource_id {
  value = azurerm_automation_account.account.id
}

output automation_account_dsc_server_endpoint {
  value = azurerm_automation_account.account.dsc_server_endpoint
}

output automation_account_dsc_primary_access_key {
  value = azurerm_automation_account.account.dsc_primary_access_key
}

output automation_account_dsc_secondary_access_key {
  value = azurerm_automation_account.account.dsc_secondary_access_key
}


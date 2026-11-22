output "principal_id" {
  value = azurerm_function_app.funcapp.identity.0.principal_id
}

output "id" {
  value = azurerm_function_app.funcapp.id
}

output "default_hostname" {
  value = azurerm_function_app.funcapp.default_hostname
}

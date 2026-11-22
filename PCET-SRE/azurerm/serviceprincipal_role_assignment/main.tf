
data "azurerm_azuread_application" "aad-app" {
  name = var.aad_service_principal_name
}

data "azurerm_azuread_service_principal" "aad-sp" {
  application_id = azurerm_azuread_application.aad-app.application_id
}

data "azurerm_azuread_service_principal_password" "aad-sp-password" {
  service_principal_id = azurerm_azuread_service_principal.aad-sp.id
}

resource "azurerm_role_assignment" "acr-assignment" {
  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = azurerm_azuread_service_principal_password.aad-sp-password.service_principal_id
}

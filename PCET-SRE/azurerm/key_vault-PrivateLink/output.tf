 output "keyvault" {
   value = azurerm_key_vault.keyvault
 }

 output "private_keyvault" {
   value = azurerm_private_endpoint.keyvault
 }

# /* Remove KV PrivateLink IP output until upgrade to AzureRM 2.0 Provider
# output kv_private_ip {
#   value = azurerm_private_endpoint.keyvault.private_service_connection[0].private_ip_address
# }*/
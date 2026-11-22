output "storage_account" {
  value = azurerm_storage_account.terraform_state
}

output "storage_container" {
  value = azurerm_storage_container.terraform_state
}
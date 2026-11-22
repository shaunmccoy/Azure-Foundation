
provider "azurerm" {
  features {}
  subscription_id   = var.subscription_id
  tenant_id         = var.tenant_id
}


resource "azurerm_resource_group" "adls_rg" {
  name          = var.resource_group_name
  location      = var.location
  tags          = var.tags
}

resource "azurerm_virtual_network" "adls2_vnet" {
  name                = "data_lake_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.adls_rg.location
  resource_group_name = azurerm_resource_group.adls_rg.name

}

resource "azurerm_subnet" "adls2_subnet" {
  name                 = "data_lake_subnet"
  resource_group_name  = azurerm_resource_group.adls_rg.name
  virtual_network_name = azurerm_virtual_network.adls2_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

module "data_lake_storage" {
  source =  "../../../PCET-SRE/azurerm/data_lake_storage"
 
  # Resource group parameters  
  resource_group_name = azurerm_resource_group.adls_rg.name
  location            = var.location
  # Storage Account parameters
  storage_account_name     = var.storage_account_name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  is_hns_enabled           = var.is_hns_enabled
  secure_dependent_resources = var.secure_dependent_resources
  # Gen2 ADLS parameters
  data_lake_name            = var.data_lake_name
  private_endpoint_name     = var.private_endpoint_name
  subnet_id                 = azurerm_subnet.adls2_subnet.id
  tags                      = var.tags
}

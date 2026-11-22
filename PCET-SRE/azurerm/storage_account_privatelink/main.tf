locals {
  # Common tags to be assigned to all resources
  common_tags = {
    TLA          = var.tla
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
  }
}

data "azurerm_client_config" "current"{
}

data "azurerm_resource_group" "storage" {
  name     = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name 
}

data "azurerm_subnet" "storage" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_subnet" "subnets" {
  count = length(data.azurerm_virtual_network.vnet.subnets)
  data "azurerm_client_config" "current"{
}

data "azurerm_resource_group" "storage" {
  name     = var.resource_group_name
  
}

data "azurerm_subnet" "storage" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}


resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  
  network_rules{
    default_action="Deny"
    virtual_network_subnet_ids = [for value in data.azurerm_subnet.subnets: value.id]

 network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    virtual_network_subnet_ids = [data.azurerm_subnet.storage.id]

  }
   tags = {
    TLA          = var.tla
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
  }
}

resource "azurerm_private_endpoint" "storage" {
  name                = azurerm_storage_account.storage.name
  location            = azurerm_storage_account.storage.location
  resource_group_name = data.azurerm_resource_group.storage.name
  subnet_id           = data.azurerm_subnet.storage.id

  private_service_connection {
    name                           = azurerm_storage_account.storage.name
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_endpoint" "storage" {
  name                = azurerm_storage_account.storage.name
  location            = azurerm_storage_account.storage.location
  resource_group_name = data.azurerm_resource_group.storage.name
  subnet_id           = data.azurerm_subnet.storage.id

  private_service_connection {
    name                           = azurerm_storage_account.storage.name
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = <<EOT
az login --identity
az account set -s ${data.azurerm_client_config.current.subscription_id}
az network vnet subnet update -n ${var.subnet_name} --vnet-name ${var.vnet_name} -g ${var.vnet_resource_group_name} --service-endpoints Microsoft.Storage
EOT
  }
}


# data lake module Gen2
     #1. Creates storage account with Gen2 HNS storage
     #2. Creates storage account end point
     #3. Creates ADLS2 data lake namespace

resource "azurerm_storage_account" "adls" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  is_hns_enabled           = var.is_hns_enabled
  
}

resource "azurerm_storage_container" "adls_container" {
  name                  = "${var.storage_account_name}-container"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "adls_storage" {
  count = var.secure_dependent_resources ? 1 : 0
  resource_group_name  = var.resource_group_name
  storage_account_name = azurerm_storage_account.adls.name
  default_action             = "Deny"
  virtual_network_subnet_ids = var.subnet_id
  bypass                     = ["AzureServices"]
}


resource "azurerm_storage_data_lake_gen2_filesystem" "adls2" {
  name               = var.data_lake_name
  storage_account_id = azurerm_storage_account.adls.id
  properties = {
    hello = "aGVsbG8="
  }
}

resource "azurerm_private_endpoint" "adls2_endpoint" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  depends_on          = [ azurerm_storage_account.adls ]

  private_service_connection {
    name                           = var.data_lake_name
    private_connection_resource_id = azurerm_storage_account.adls.id
    is_manual_connection           = false
    #subresource_names              = ["blob"]
    subresource_names              = ["dfs"]
  }
}

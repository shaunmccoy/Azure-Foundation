
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  
  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  access_tier              = var.access_tier
  enable_https_traffic_only = true
  allow_blob_public_access  = false
  
  blob_properties  {

    cors_rule { 
    
      allowed_headers     = ["*"]
      allowed_origins     = ["*"] 
      allowed_methods     = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT","PATCH"]
      exposed_headers     = ["*"]
      max_age_in_seconds  = 5
      } 
        
    }

  tags                     = var.tags
  
}

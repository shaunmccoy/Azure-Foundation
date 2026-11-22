# Storage Account Private Link

This module will define a private link for storage accounts.

## Files

| File Name | Description |
| --- | --- |
| `storage_account_privatelink_variables.tf` | Module Variables |
| `storage_account_privatelink_outputs.tf` | Output Variables |
| `storage_account_privatelink_versions.tf` | Terraform software and provider requirements |
| `storage_account_privatelink.tf` | Main resource definitions |

## Example Usage
```
module "storage_account_privatelink_tfstate" {
  source                          = "../../modules/storage_account_privatelink"
  resource_tags                   = local.common_tags
  resource_group_name             = azurerm_resource_group.storage.name
  storage_name                    = "nt${lower(var.env)}hub${lower(local.loc_code)}tfstate01"
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  privatelink_resource_group_name = azurerm_resource_group.privatelink.name
  vnet_resource_group_name        = azurerm_resource_group.vnet.name
  vnet_name                       = module.vnet.vnet_name  
  log_analytics_workspace_id      = local.log_analytics_workspace_id
}
```
# Recovery Vault 

This module will define a standard recovery vault along with log diagnostics that go with it. 

## Example Usage
```
module "recovery_vault" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/recovery_vault?ref=1.0.1"

    vault_name                    = var.vault_name

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    log_analytics_workspace_id    = var.log_analytics_workspace_id
    tags                          = var.tags

}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Recovery Vault Variables | vault_name | Y | Name for the recovery services vault |
|  | vault_sku |  | SKU for the recovery vault. Defaults to ```Standard```.|
|  | soft_delete_enabled |  | Default ```true```. |
| Common | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
| Log Diagnostic Variables | log_analytics_workspace_id |  | Will not set up log diagnostics if omitted |
|  | diagnostics_name |  | Defaults if not provided |
|  | diagnostic_log_category_list |  | Defaults to all available log categories |
|  | log_analytics_retention_days |  | Defaults to 0 -- for all time |

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| vault_resource_id | Recovery Services Vault resource id|

## Release Notes

> Initial Release

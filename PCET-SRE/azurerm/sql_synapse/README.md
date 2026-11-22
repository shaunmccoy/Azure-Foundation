# SQL Synapse

This module will deploy an Azure SQL Synapse along with underlying storage and dedicated SQL pool.

> The private link must be registered with DNS
The output ```????``` has the needed FQDN for the private link.

## Example Usage
```
module "sql_synapse" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/sql_synapse?ref=1.0.1"

    resource_group_name                     = var.resource_group_name
    location                                = azurerm_resource_group.example_test_rg.location
    #sql_pool_sku_name                               = var.sql_pool_sku_name
    tags                                    = var.tags
    storage_data_lake_gen2_filesystem_name  = var.storage_data_lake_gen2_filesystem_name
    storage_account_name                    = var.storage_account_name
    synapse_workspace_name                  = var.synapse_workspace_name
    synapse_sql_pool_name                   = "examplepool"
    sql_administrator_login_password        = "SuperSecret!"

    log_analytics_workspace_id              = var.log_analytics_workspace_id

}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Synapse Variables | synapse_workspace_name | Y | Name for the Synapse workspace |
|  | storage_account_name | Y  | Name for the underlying storage account for the workspace.|
|  | storage_data_lake_gen2_filesystem_name | Y  | Name for the underlying data lake filesyatem for the workspace.|
| SQL Pool Variables | synapse_sql_pool_name | | Optional SQL Pool name. A dedicated pool will not be created if not provided.|
|  | sql_pool_sku_name |  | Defaults to ```DW100c```.|
|  | sql_administrator_login |  | Defaults to ```azdoadmin```.|
|  | sql_administrator_login_password |  | Required if dedicated SQL pool is wanted.|
| Common | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
| Log Diagnostic Variables | log_analytics_workspace_id |  | Will not set up log diagnostics if omitted |
|  | diagnostics_name |  | Defaults if not provided |
|  | synapse_diagnostic_log_category_list |  | Defaults to all available log categories for Synapse |
|  | sqlpool_diagnostic_log_category_list |  | Defaults to all available log categories for a dedicated SQL pool |
|  | log_analytics_retention_days |  | Defaults to 0 -- for all time |

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| synapse_workspace_id | Resource ID for the Synapse workspace. |

## Release Notes

> Initial release
# Event Data System Topics 

This module will define a event data system data topic along with an option for diagnostics.

> This module is only to be used with System Topics!

## Example Usage
```
module "event_grid_system" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/event_grid_system?ref=1.0.1"

    deployment_name                 = var.deployment_name
    subscription_id                 = var.subscription_id

    event_grid_name                 = var.event_grid_name
    event_source_resource_id        = azurerm_storage_account.example.id
    event_source_topic_type         = "Microsoft.Storage.StorageAccounts"

    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.test_rg.name
    location                        = var.location
    tags                            = var.tags

}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Event Grid Variables | event_grid_name | Y | Name of the event grid |
|  | event_source_resource_id | Y | Resource Id for which the event grid will gather data |
|  | event_source_topic_type | Y | The type of resource for the soruce (e.g. ```Microsoft.Storage.StorageAccounts```). |
| Common | deployment_name | Y | Name of the ARM template deployment used to create the data factory |
|  | subscription_id | Y | |
|  | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
| Log Diagnostic Variables | log_analytics_workspace_id |  | Will not set up log diagnostics if omitted |
|  | diagnostics_name |  | Defaults if not provided |
|  | log_analytics_retention_days |  | Defaults to 0 -- for all time |

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| event_grid_resource_id | Event grid resource id |


## Release Notes

> Initial Release

## Developer Notes

> Use of ARM Templates for Data Factory Construction.

At the time of this writing, Terraform does not support event grids for system topics. A resource for other types of event grids are available, but not for system topics. Consequently, the event grid needs to be created by ARM template. When this changes and a formal resource for event grid system topics is added, this module should be refactored to use the Terraform resource.
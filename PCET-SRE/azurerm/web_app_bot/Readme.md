# Web App Bot 

This module will define a standard web app bot along with log diagnostics that go with it. 

Log Diagnostics are optional. 

## Example Usage
```
module "web_app_bot" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/web_app_bot?ref=1.0.1"

    bot_name            = var.bot_name
    bot_sku             = var.bot_sku
    bot_application_id  = var.bot_application_id
    global_app_ind      = var.global_app_ind
    bot_endpoint        = var.bot_endpoint

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
| Web App Bot Variables | bot_name | Y |  |
|  | bot_sku | Y | Sku name for the web app bot |
|  | bot_application_id | Y | The applicastion id (an app service from a app service plan) associated with the web app bot |
|  | bot_endpoint | Y | End point for the app service associated with the ```application_id``` |
|  | global_app_ind | N | Defaults to ```true```. Indicates if the location for the web_app_bot should be designated as ```global```. |
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
| bot_id | Web App Bot Resource Id|

## Release Notes

> Initial Release

## Developer Notes

> This module relies on an App Service and App Service Plan

These capabilities are not provided in this module as there are other SRE modules to create these.
# Key Vault

This module will deploy an Azure Key Vault and Access Policy.

> The private link must be registered with DNS
The output ```keyvault``` has the needed FQDN for the private link.

## Example Usage
```
module "key_vault" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/key_vault?ref=1.0.1"

    name                          = var.vault_name

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    secure_resources              = true
    object_id_list                = [data.azurerm_client_config.current.object_id]
    subnet_id                     = azurerm_subnet.keyvault_subnet.id

    key_permissions               = ["get"]
    secret_permissions            = ["get"]

    log_analytics_workspace_id    = var.log_analytics_workspace_id
    tags                          = var.tags

}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Key Vault Variables | name | Y | Name for the key vault |
|  | secure_resources | Y  | Toggle for activating private endpoint access. Defaults to ```true```.|
|  | secure_resources | Y  | Toggle for activating private endpoint access. Defaults to ```true```.|
|  | subnet_id | Y | Subnet ID key vault.|
| Key Vault Policy Variables | application_id |  | The object ID of an Application in Azure Active Directory. Defaults to ```null```.|
|  | certificate_permissions |  | Defaults to an empty list.|
|  | enabled_for_deployment |  | Defaults to ```false```.|
|  | enabled_for_template_deployment |  | Defaults to ```false```.|
|  | enable_rbac_authorization |  | Defaults to ```false```.|
|  | key_permissions |  | Defaults to ```["get"]```.|
|  | object_id_list |  | Defaults to the object consuming this module. |
|  | purge_protection_enabled |  | Defaults to ```false```.|
|  | secret_permissions |  | Defaults to ```["get"]```.|
|  | storage_permissions |  | Defaults to an empty list.|
|  | sku_name |  | SKU for the key vault. Defaults to ```standard```.|
|  | soft_delete_retention_days |  | Defaults to ```90```.|
|  | tenant_id |  | Defaults to the tenant consuming this module. |
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
| key_vault | Exports all resources used within this module. |

## Release Notes

> New Release (March 2021)

Variable ```object_id``` is now a list and has been renamed to ```object_id_list```. 

Modules to be deprecated are below. Consumers should transition to module ```key_vault```.
* key_vault_access_policy
* key_vault_multiple_access_policy
* key_vault-PrivateLink

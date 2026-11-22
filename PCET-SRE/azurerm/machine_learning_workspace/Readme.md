# Machine Learning Workspace 

This module will define a standard machine learning workspace. 

> Subnet requirements
Machine learning has specific requirements for the subnet in which it resides.

* Private link endpoint network policies must be set to ```true```
* The following service endpoints must be defined: ```Microsoft.Storage```, ```Microsoft.KeyVault```, ```Microsoft.ContainerRegistry```
* Outputs ```private_endpoint_storage_file_fqdn```, ```private_endpoint_storage_blob_fqdn```, ```private_endpoint_vault_fqdn```, and ```private_endpoint_registry_fqdn``` must resolve in DNS before argument ```secure_dependent_resources``` is set to ```true```. Currently, there is a manual process to place the A-record entry in InfoBlox.
* All machine learning workspace private links must also resolve to DNS for the same reason. They are not outputs as the workspace is created by ARM template and is unavailable to this module. 

## Example Usage
```
module "machine_learning_workspace" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/machine_learning_workspace?ref=1.0.1"

    deployment_name                 = var.deployment_name
    machine_learning_workspace_name = var.machine_learning_workspace_name
    workspace_private_endpoint_name = var.private_endpoint_name
    secure_dependent_resources      = true

    key_vault_name                  = "examplelabmlvault"
    storage_account_name            = "examplelabmlstorage"
    storage_account_account_replication = "LRS"
    
    container_registry_name         = "examplelabmlcontainerreg"
    app_insights_name               = "machine-learning-app-insights"

    vnet_name                       = azurerm_virtual_network.machine_learning.name
    vnet_rg_name                    = azurerm_resource_group.test_rg.name
    subnet_name                     = azurerm_subnet.machine_learning.name

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
| Machine Learning Variables | machine_learning_workspace_name | Y |  |
|  | machine_learning_workplace_sku |  | Sku for the workspace.  Defaults to ```Basic```. |
| Networking | vnet_name | Y | Name for the VNet used by machine learning |
|  | vnet_rg_name | Y | Resource group name for ```vnet_name```. |
|  | subnet_name | Y | Subnet in ```vnet_name``` to be used for machine learning.|
|  | secure_dependent_resources | Y | Indicates if underlying resources are to be restricted to access by private link. Must be ```false``` before DNS entries have been made.|
| Common | deployment_name | Y | Name of the ARM template deployment sued to create the machine learning workspace |
|  | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
| Log Diagnostic Variables | log_analytics_workspace_id |  | Will not set up log diagnostics if omitted |
|  | diagnostics_name |  | Defaults if not provided |
|  | machine_learning_diagnostic_log_category_list |  | Defaults to all available log categories |
|  | vault_diagnostic_log_category_list |  | Defaults to all available log categories |
|  | registry_diagnostic_log_category_list |  | Defaults to all available log categories |
|  | log_analytics_retention_days |  | Defaults to 0 -- for all time |
| Key Vault Variables | key_vault_name | Y | Key vault name |
|  | key_vault_sku |  | Defaults to ```standard```. |
|  | key_vault_disk_purge_protection |  | Defaults to ```true``` |
|  | key_vault_disk_soft_delete_days |  | Defaults to ```7``` |
| Storage Account Variables | storage_account_name | Y | Storage account name |
|  | storage_account_account_tier |  | Defaults to ```Standard```. |
|  | storage_account_account_replication |  | Defaults to ```GRS```. |
| Container Registry Variables | container_registry_name | Y | Container registry name |
|  | container_registry_sku |  | Defaults to ```Premium```. |
|  | container_registry_geo_locations |  | Defaults to ```centralus``` and ```eastus2```. |
| Application Insights Variables | app_insights_name | Y | Container registry name |
|  | app_insights_app_type |  | Defaults to ```web```. |

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| private_endpoint_storage_file_resource_id | Default storage account private link file resource id|
| private_endpoint_storage_blob_resource_id | Default storage account private link blob resource id|
| private_endpoint_vault_resource_id | Default key vault private link resource id|
| private_endpoint_registry_resource_id | Default container registry private link resource id|
| private_endpoint_storage_file_fqdn | Default storage account private link file FQDN |
| private_endpoint_storage_blob_fqdn | Default storage account private link blob FQDN|
| private_endpoint_vault_fqdn | Default key vault private link FQDN|
| private_endpoint_registry_fqdn | Default container registry private link FQDN|
| private_endpoint_storage_file_ip_addresses | Default storage account private link file IP address list |
| private_endpoint_storage_blob_ip_addresses | Default storage account private link blob IP address list|
| private_endpoint_vault_ip_addresses | Default key vault private link IP address list|
| private_endpoint_registry_ip_addresses | Default container registry private link IP address list|

## Release Notes

> Initial Release


## Developer Notes

> Use of ARM Templates for machine learning workspace construction.

At the time of this writing, Terraform [```azurerm_machine_learning_workspace```](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_workspace) resource does not support VNet integration options. Consequently, the machine learning workspace needs to be created by ARM template. When these changes and VNet integration features are added, this module should be refactored to use the Terraform resource.
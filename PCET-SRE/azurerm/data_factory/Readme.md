# Data Factory 

This module will define a standard data Factory along with log diagnostics and private endpoint that go with it. A couple of notes:

Security policies require VNet integration. This module enforces that. The subnet provided *must* have network policies for private link endpoints set to ```true```.

Log Diagnostics are optional. 

The output ```private_endpoint_fqdn``` value must resolve in DNS. Currently, there is a manual process to place the A-record entry in InfoBlox.

## Example Usage
```
module "data_factory" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/data_factory?ref=1.0.1"

    deployment_name                 = var.deployment_name
    subscription_id                 = var.subscription_id
    subnet_id                       = azurerm_subnet.data_factory.id
    private_endpoint_name           = var.private_endpoint_name
    data_factory_name               = var.data_factory_name
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
| Data Factory Variables | data_factory_name | Y |  |
|  | subnet_id | Y | Policy requires VNet integration |
|  | private_endpoint_name | Y | Name of the private endpoint that services the data factory. |
| Common | deployment_name | Y | Name of the ARM template deployment sued to create the data factory |
|  | subscription_id | Y | |
|  | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
| Log Diagnostic Variables | log_analytics_workspace_id |  | Will not set up log diagnostics if omitted |
|  | diagnostics_name |  | Defaults if not provided |
|  | diagnostic_log_category_list |  | Defaults to all available log categories |
|  | log_analytics_retention_days |  | Defaults to 0 -- for all time |
| Azure Devops Repository Variables | devops_configure_later |  | Defaults to ```true```. Set to false if DevOps integration desired |
|  | devops_account_name |  | Defaults to ```example-org``` |
|  | devops_project_name | | Required if ```devops_configure_later = false``` |
|  | devops_repo_name |  | Required if ```devops_configure_later = false``` |
|  | devops_branch_name |  | Defaults to 'master' |
|  | devops_root_folder |  | Defaults to '/' |

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| data_factory_name | Data factory name|
| data_factory_resource_id | data factory resource id |
| private_endpoint_resource_id | factory private endpoint resource id |
| data_factory_arm_resource_id | factory ARM deployment resource id |
| private_endpoint_fqdn | FQDN/DNS entry required to resolve to the private IP address in DNS |
| private_endpoint_ip_addresses | private ip address assigned to the FQDN above |

## Release Notes

> Initial Release

## Developer Notes

> Use of ARM Templates for Data Factory Construction.

At the time of this writing, Terraform [```azurerm_data_factory```](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory) resource does not support VNet integration options. Consequently, the data factory needs to be created by ARM template. When these changes and VNet integration features are added, this module should be refactored to use the Terraform resource.
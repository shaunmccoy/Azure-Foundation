# data lake 

This module will define a standard data lake along with the exposing storage account associated with it (blob) as private endpoint. A couple of notes:

Security policies require VNet integration. This module enforces that. The subnet provided *must* have network policies for private link endpoints set to ```true```.

Log Diagnostics are optional (Right no log of data lake gen2 and only storage account is preview only)

The output ```private_endpoint_fqdn``` value must resolve in DNS. Currently, there is a manual process to place the A-record entry in InfoBlox.

## Example Usage
```
module "data_lake_storage" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/data_factory?ref=1.0.1"

    subscription_id                 = var.subscription_id
    subnet_id                       = azurerm_subnet.adls.id
    private_endpoint_name           = var.private_endpoint_name
    data_lake_name                  = var.data_lake _name
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.rg.name
    location                        = var.location
    tags                            = var.tags

}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| data lake Variables | data_lake_name | Y |  |
|  | subnet_id | Y | Policy requires VNet integration |
|  | private_endpoint_name | Y | Name of the private endpoint that services the data lake. |
| Storage | storage_account_name | Y | |
|  |account_tier | Y |Storage Account tier level  |
|  | account_replication_type | Y |Storage Account Replication type e.g. LRS  |
|  | account_kind | Y |storage account kind parameter  |
|  | is_hns_enabled | Y | This is set to True|
| Common |  resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
|  | log_analytics_workspace_id | Y | Log workspace analytics id |




## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| data_lake_name | data lake name |
| data_lake_id | Reference to Gen2 data lake resource id |
| storage_account_id | data lake storage account id |
| storage_account_name | data lake storage account name |
| storage_dfs_endpoint | data lake storage account storage_dfs_endpoint |
| private_endpoint_fqdn | FQDN/DNS entry required to resolve to the private IP address in DNS |
| private_endpoint_ip_addresses | private ip address assigned to the FQDN above |

## Release Notes

> Initial Release for data lake

## Developer Notes

> Use of ARM Templates for data lake Construction.
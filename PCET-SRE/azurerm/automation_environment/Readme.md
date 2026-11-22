# Automation Environment 

This module will define a standard automation environment that adheres to organisation security standards and is capable of executing runbooks. 

## Example Usage
```
module "automation_environment" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/automation_environment?ref=1.0.1"

    account_name                  = var.account_name

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    log_analytics_workspace_name  = "${var.account_name}-WORKSPACE"
    tags                          = var.tags

}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Automation Account Variables | worker_scale_set_name | Y | Name for the automation account |
|  | account_sku_name |  | Automation account sku name. Defaults to ```Basic```.|
| Hybrid Worker Variables | worker_scale_set_name | Y | Name for the vm scale set used for Hybrid workers |
|  | worker_admin_public_key | Y | Worker scale set admin public key for ssh.|
|  | worker_scale_set_nic_name | Y | Worker scale set VM network interface name.|
|  | worker_subnet_id | Y | Worker scale set subnet id.|
|  | hybrid_worker_group_name | Y | Hybrid worker group name.|
|  | worker_scale_set_sku |  | Worker scale set sku name. Defaults to ```Standard_A2_v2```.|
|  | worker_scale_set_vm_count |  | Worker scale set VM count. Defaults to ```1```.|
|  | worker_admin_username |  | Worker scale set VM admin user name. Defaults to ```azdoadmin```.|
|  | worker_managed_id_list |  | Worker scale set managed id list. Defaults to none.|
|  | http_proxy |  | Http proxy to be used by Hybrid worker VMs. Defaults to ```http://proxy.example.com:80/```.|
|  | https_proxy |  | Https proxy to be used by Hybrid worker VMs. Defaults to ```http://proxy.example.com:80/```.|
|  | no_proxy_udr |  | Worker scale set VM count. Defaults to blank.|
| Common | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
| Log Diagnostic Variables | log_analytics_workspace_id | Y | Required for automation account setup |
|  | diagnostics_name |  | Defaults if not provided |
|  | diagnostic_log_category_list |  | Defaults to all available log categories |
|  | log_analytics_retention_days |  | Defaults to 0 -- for all time |

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| automation_account_resource_id | Automation account resource id |
| automation_account_dsc_server_endpoint | Automation account DSC server endpoint |
| automation_account_dsc_primary_access_key | Automation account DSC primary access key |
| automation_account_dsc_secondary_access_key | Automation account DSC secondary access key |

## Release Notes

> Initial Release

## Developer Notes

> One-to-one relationship between Automation accounts and log analytics workspaces

This module creates a log analytics workspace for the automation account. Reasons for this are as follows:

* Automation accounts *must* be assigned to a log analytics workspace when using Hybrid worker VMs
* Only one automation account can be assigned to a log analytics workspace. 
    * The central workspace in the hub cannot be used as there are multiple spokes/applications with automation needs.

> Output from the VM startup script is found in file `/var/log/cloud-init-output.log`

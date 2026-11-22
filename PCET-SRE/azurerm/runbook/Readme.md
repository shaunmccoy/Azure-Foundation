# Automation Runbook 

This module will define a runbook along with scheduling for the runbook if wanted. 

## Example Usage
```
module "runbook" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/runbook?ref=1.0.1"

    runbook_name                  = var.runbook_name
    runbook_description           = var.runbook_description
    runbook_content               = file("${path.module}/runbook-test.PS1")
    account_name                  = var.account_name
    runbook_type                  = var.runbook_type
    schedule_config               = var.schedule_config
    hybrid_worker_group_name      = local.hybrid_worker_group_name
    
    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    tags                          = var.tags
}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Runbook Variables | runbook_name | Y | Name for the runbook |
|  | account_name | Y | Automation account name for the runbook. |
|  | runbook_type | Y | Specifies the type of runbook. Value options given [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook#runbook_type) |
|  | runbook_content | Y | Provides the source code for the runbook. |
|  | runbook_description | | Provides a description for the runbook. Defaults to blank. |
|  | log_verbose | | Toggle for verbose logging for the runbook. Defaults to ```true``` |
|  | log_progress | | Toggle for progress logging for the runbook. Defaults to ```true``` |
| Scheduling Variables | schedule_config | | Schedules runbook execution. See Schedule Configuration section for details. |
|  | hybrid_worker_group_name | | Hybrid worker group name for executing the workbook. Required if ```schedule_config``` provided.|
| Common | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |

### Schedule Configuration 

Scheduling information is optional. If provided, the runbook execution will be scheduled.

Input for variable ```schedule_config``` is complex.  An example follows:
```
schedule_config = {
    weekly-schedule = {
        frequency = "Week"
        week_days = ["Monday"]

        parameters = {                      # Optional parameters for the runbook for this schedule
            flintstone-name = "Fred"
            barney-name = "Barney"
        }
    }
    monthly-schedule = {
        frequency = "Month"
        month_days = [15, -1]
    }
}

```

> A complete list of scheduling parameter documentation can be found in Terraform documentation [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule#name).

The following arguments are supported:
* freqency (required)
* description
* interval
* start_time
* expiry_time
* timezone
* week_days
* month_days

> Multiple schedules are fine.
* They must have unique names (```weekly-schedule``` and ```monthly-schedule```)

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| runbook_resource_id | Runbook resource id |

## Release Notes

> Initial Release

## Developer Notes

> Scheduling option ```monthly_occurance``` isn't currently supported.

Given that [```monthly_occurance```](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule#monthly_occurrence) is a block, adding it as an optional feature for ```schedule_config``` would have greatly increased complexity. At the time of this writing, there's no requirement for it. It is technically possible to add if a firm requirement arises.

> Explicit specification of ```schedule_config``` fields was avoided as many are optional.

It is best practice to explicitly specify objects (See variable ```nat_pool_config``` in module ```load_balancer```). As ```schedule_config``` has optional fields, this isn't possible.

At the time of this writing, support for "optional" fields in a map is in development. It can be used if experimental features are active. As we can't guarantee that consumers will activate the required experimental features, 

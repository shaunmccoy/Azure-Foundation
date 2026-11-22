# Log Analytics 

This module will define a standard log analytics workspace and optionally multiple solutions. 

## Example Usage
```
module "loganalytics_workspace" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/loganalytics_workspace?ref=1.0.1"

    log_analytics_workspace_name  = var.log_analytics_workspace_name
    solution_config               = var.solution_config
    sku                           = "PerGB2018"
    retention_in_days             = 30

    resource_group_name           = azurerm_resource_group.test_rg.name
    location                      = azurerm_resource_group.test_rg.location
    tags                          = var.tags
}
```

## Variables

This section details variable inputs for this module.

resource_group_name
location 
log_analytics_workspace_name 
sku
retention_in_days 
tags 
solution_config
| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Log Analytics Variables | log_analytics_workspace_name | Y | Name for the log analytics workspace |
|  | sku | Y | SKU to use for the log analytics workspace |
|  | retention_in_days | Y | The number of days logs are retained |
|  | solution_config |  | See Solution Configuration Options section |
| Common | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags | Y |  |

### Solution Configuration options

This module can create one or more solutions that are associated with the log analytics workspace.

Input for variable ```solution_config``` is complex.  Examples needed at the time of this writing follow:

```
solution_config = {
    SQLAdvancedThreatProtection = {
        publisher = "Microsoft"
        product   = "OMSGallery/SQLAdvancedThreatProtection"
    }
    SQLVulnerabilityAssessment = {
        publisher = "Microsoft"
        product   = "OMSGallery/SQLVulnerabilityAssessment"
    }
}

```

> Multiple solution configurations are fine.
* They must have unique names (```SQLAdvancedThreatProtection``` and ```LbRule2```)
* If not blank, the ```backend_address_pool_name``` must be defined with ```backend_address_pool_list```
* If not blank, the ```probe_name``` must be defined with ```probe_config```

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| id | Log Analytics resource id|



## Release Notes

> Added optional solution capability
* No changes needed to implement this release

> Initial Release

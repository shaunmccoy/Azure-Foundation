# Load Balancer 

This module will define a standard internal load balancer along with log diagnostics and private endpoint that go with it. 

## Example Usage
```
module "load_balancer" {
    source                          = "git::https://dev.azure.com/example-org/PCET-SRE/_git/terraform_modules//azurerm/load_balancer?ref=1.0.1"

    backend_address_pool_list       = var.backend_address_pool_list
    frontend_ip_config              = var.frontend_ip_config
    nat_pool_config                 = var.nat_pool_config
    nat_rule_config                 = var.nat_rule_config
    probe_config                    = var.probe_config
    lb_rule_config                  = var.lb_rule_config
    load_balancer_name              = var.load_balancer_name
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    resource_group_name             = azurerm_resource_group.test_rg.name
    location                        = var.location
    tags                            = var.tags


}

# To add VMs to a backend address pool, you must do the association as follows.
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.testers.id
  ip_configuration_name   = "fred-test-vm-NIC1-IPConfig"
  backend_address_pool_id = module.load_balancer.load_balancer_backend_pool_name_id_map["backend1"]
}
```

## Variables

This section details variable inputs for this module.

| Category | Variable Name | Required | Notes |
| -- | -- | -- | -- | 
| Load Balancer Variables | load_balancer_name | Y | Name for the load balancer |
|  | frontend_ip_config |  | See Frontend IP Configuration section for details. |
|  | backend_address_pool_list |  | See Backend address Pools section for details. |
| Common | resource_group_name | Y |  |
|  | location | Y |  |
|  | tags |  | Defaults to no tags. |
| Log Diagnostic Variables | log_analytics_workspace_id |  | Will not set up log diagnostics if omitted |
|  | diagnostics_name |  | Defaults if not provided |
|  | diagnostic_log_category_list |  | Defaults to all available log categories |
|  | log_analytics_retention_days |  | Defaults to 0 -- for all time |


> Backend address pool names in the list provided must be unique.

### Frontend IP Configuration 
Input for variable ```frontend_ip_config``` is complex.  An example follows:
```
frontend_ip_config = {
    MyIpOne = {
        subnet_id           = "/subscriptions/fb55307e-SCRUBBED"
        private_ip_address  = "10.0.1.4"
    }
}

```

> ```private_ip_address``` can be blank (```""```). If the private ip is blank, it will be dynamically determined from the subnet id provided. If provided, the private ip must fit in the subnet listed.

> Multiple Front-end IP configurations are fine.
* They must have unique names (```MyIpOne``` and ```MyIpTwo```)
* The private IP address must be unique 
```
frontend_ip_config = {
    MyIpOne = {
        subnet_id           = "/subscriptions/fb55307e-SCRUBBED"
        private_ip_address  = "10.0.1.4"
    }
    MyIpTwo = {
        subnet_id           = "/subscriptions/fb55307e-SCRUBBED"
        private_ip_address  = "10.0.1.5"
    }
}

```

### Backend address Pools

This module can create simple backend address pools meant to be used with virtual machine scale sets or VMs. For backend address pools that specifically list member virtual machines or reference VM scale sets, those should be added separately.  An example follows:
```
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.testers.id
  ip_configuration_name   = "fred-test-vm-NIC1-IPConfig"
  backend_address_pool_id = module.load_balancer.load_balancer_backend_pool_name_id_map["backend1"]
}
```

### NAT Pools

This module can create nat pools that are associated with the load balancer.

Input for variable ```nat_pool_config``` is complex.  An example follows:
```
nat_pool_config = {
    MyNatPool1 = {
        frontend_ip_configuration_name  = "MyIpOne"
        protocol                        = "Tcp"     # Values are Tcp or Udp
        frontend_port_start             = 80
        frontend_port_end               = 81
        backend_port                    = 80
    }
}

```

> Multiple NAT Pool configurations are fine.
* They must have unique names (```MyNatPool1``` and ```MyNatPool2```)
* The ```frontend_ip_configuration_name``` must be defined in ```frontend_ip_config```

### NAT Rules

This module can create nat rules that are associated with the load balancer.

Input for variable ```nat_rule_config``` is complex.  An example follows:
```
nat_rule_config = {
    MyNatRule2 = {
        frontend_ip_configuration_name  = "MyIpTwo"
        protocol                        = "Tcp"         # Values are Tcp, Udp, or All
        frontend_port                   = 80
        backend_port                    = 80
    }
}

```

> Multiple NAT Rule configurations are fine.
* They must have unique names (```MyNatRule1``` and ```MyNatRule2```)
* The ```frontend_ip_configuration_name``` must be defined in ```frontend_ip_config```

### Load Balancer Probes

This module can create load balancer probes that are associated with the load balancer.

Input for variable ```probe_config``` is complex.  An example follows:
```
probe_config = {
    MyProbe1 = {
        port                            = 23
        protocol                        = "Tcp"         # Allowed values are Http, Https, or Tcp
        request_path                    = ""
    }
}

```

> Multiple load balancer probe configurations are fine.
* They must have unique names (```MyProbe1``` and ```MyProbe2```)
* If the protocol is ```http``` or ```https```, the ```request_path``` must not be blank.

### Load Balancer Rules

This module can create load balancer rules that are associated with the load balancer.

Input for variable ```lb_rule_config``` is complex.  An example follows:
```
lb_rule_config = {
    LbRule1 = {
        frontend_ip_configuration_name  = "MyIpTwo"
        protocol                        = "Tcp"         # Values are Tcp, Udp, or All
        frontend_port                   = 23
        backend_address_pool_name       = "backend2"
        backend_port                    = 23
        probe_name                      = "MyProbe1"
    }
}

```

> Multiple load balancer rule configurations are fine.
* They must have unique names (```LbRule1``` and ```LbRule2```)
* If not blank, the ```backend_address_pool_name``` must be defined with ```backend_address_pool_list```
* If not blank, the ```probe_name``` must be defined with ```probe_config```

## Output Variables

This section details variables that are exported and referencable after the module call.

| Variable Name | Notes |
| -- | -- |
| load_balancer_resource_id | Load balancer resource id|
| load_balancer_backend_pool_name_id_map | backend address pool name to resource id mapping |
| nat_pool_name_id_map | nat pool pool name to resource id mapping |
| nat_rule_name_id_map | nat rule pool name to resource id mapping |
| probe_name_id_map | probe name to resource id mapping |


## Release Notes

> Initial Release

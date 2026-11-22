# Application Gateway 

This module will define standard an application gateway.

## ToDos
* Enhance to handle SSL on the front-end along with an SSL Certificate.
* Supported configuration is basic.  Additional capabilities that might be needed are:
    * Enhanced routing rule support.
    * Enhanced health check support

## Application Considerations
> Host-based and path-based routing is supported.

Supports routing to different back-end resources by DNS host or request path.

> Different back-end resources require a separation by either host or path based route differentiator

Routing rules govern which back-end resources that handle them.  Requests for static resources backed by a storage account 
will require a different route rule then those requiring an application server or function.

## Files

| File Name | Description |
| --- | --- |
| `application_gateway_variables.tf` | Module Variables |
| `application_gateway_outputs.tf` | Output Variables |
| `application_gateway_versions.tf` | Terraform software and provider requirements |
| `application_gateway.tf` | Main resource definitions |

## Example Usage
```
module "APPLICATION_GATEWAY" {
  source                = "../../modules/application_gateway"

  app_gateway_name      = "${var.environment}TestAppGateway"
  resource_group_name   = var.resource_group_name
  location              = var.location

  gateway_ip_configuration_list     = var.gateway_ip_configuration_list
  frontend_ip_configuration_list    = var.frontend_ip_configuration_list
  frontend_port_list                = var.frontend_port_list
  backend_address_pool_list         = var.backend_address_pool_list
  backend_http_setting_list         = var.backend_http_setting_list

  http_listener_list                = var.http_listener_list
  request_routing_rule_list         = var.request_routing_rule_list
  health_probe_list                 = var.health_probe_list

}
```

## Example variable input

The variable input for this module is complex.  Here's a sample:
```
environment         = "Lab"
resource_group_name = "example_stgact_rg"
location            = "centralus"
tenant_id           = "xxxxxx"
subscription_id     = "xxxxxx"

gateway_ip_configuration_list = [
    {
        name        = "Lab-gateway"
        subnet_id   = "/subscriptions/xxxxxx/resourceGroups/example_stgact_rg/providers/Microsoft.Network/virtualNetworks/example_stgact_test-vnet/subnets/AppGatewaySubnet"
    }
]

frontend_ip_configuration_list = [
    {
        name                    = "Lab-static-site-frontend"
        public_ip_address_id    = "/subscriptions/xxxxxx/resourceGroups/example_stgact_rg/providers/Microsoft.Network/publicIPAddresses/app-gateway-public-ip"
    }
]

frontend_port_list = [
    {
        name        = "Lab-static-site-port"
        port        = 80
    }
]

backend_address_pool_list = [
    {
        name                = "Lab-static-site-backend-pool"
        fqdn_list           = ["ntstgact003-secondary.z19.web.core.windows.net"]
        ip_address_list     = []
    }
]

backend_http_setting_list = [
    {
        name                    = "Lab-static-site-backend-http"
        cookie_based_affinity   = "Disabled"
        port                    = 443
        protocol                = "Https"
        request_timeout         = 1
        probe_name              = "Lab-static-site-health"
    }
]

http_listener_list = [
    {
        name                            = "Lab-static-site-http-listener"
        frontend_ip_configuration_name  = "Lab-static-site-frontend"
        frontend_port_name              = "Lab-static-site-port"
        protocol                        = "Http"
    }
]

request_routing_rule_list = [
    {
        name                        = "Lab-static-site-routing-rule"
        rule_type                   = "Basic"
        http_listener_name          = "Lab-static-site-http-listener"
        backend_address_pool_name   = "Lab-static-site-backend-pool"
        backend_http_settings_name  = "Lab-static-site-backend-http"
    }
]

health_probe_list = [
    {
        name                    = "Lab-static-site-health"
        interval                = 30
        protocol                = "Https"
        port                    = 443
        path                    = "/"
        timeout                 = 30
        unhealthy_threshold     = 3
    }
]

```
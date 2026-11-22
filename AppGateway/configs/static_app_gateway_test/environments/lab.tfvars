environment         = "ExampleLab"
resource_group_name = "example_stgact_rg"
location            = "centralus"
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"

gateway_ip_configuration_list = [
    {
        name        = "ExampleLab-gateway"
        subnet_id   = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.Network/virtualNetworks/example_stgact_test-vnet/subnets/AppGatewaySubnet"
    }
]

frontend_ip_configuration_list = [
    {
        name                    = "ExampleLab-static-site-frontend"
        public_ip_address_id    = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.Network/publicIPAddresses/app-gateway-public-ip"
    }
]

frontend_port_list = [
    {
        name        = "ExampleLab-static-site-port"
        port        = 80
    }
]

backend_address_pool_list = [
    {
        name                = "ExampleLab-static-site-backend-pool"
        fqdn_list           = ["examplelabtestweb.z19.web.core.windows.net"]
        ip_address_list     = []
    }
]

backend_http_setting_list = [
    {
        name                    = "ExampleLab-static-site-backend-http"
        cookie_based_affinity   = "Disabled"
        port                    = 443
        protocol                = "Https"
        request_timeout         = 1
        probe_name              = "ExampleLab-static-site-health"
    }
]

http_listener_list = [
    {
        name                            = "ExampleLab-static-site-http-listener"
        frontend_ip_configuration_name  = "ExampleLab-static-site-frontend"
        frontend_port_name              = "ExampleLab-static-site-port"
        protocol                        = "Http"
    }
]

request_routing_rule_list = [
    {
        name                        = "ExampleLab-static-site-routing-rule"
        rule_type                   = "Basic"
        http_listener_name          = "ExampleLab-static-site-http-listener"
        backend_address_pool_name   = "ExampleLab-static-site-backend-pool"
        backend_http_settings_name  = "ExampleLab-static-site-backend-http"
    }
]

health_probe_list = [
    {
        name                    = "ExampleLab-static-site-health"
        interval                = 30
        protocol                = "Https"
        port                    = 443
        path                    = "/"
        timeout                 = 30
        unhealthy_threshold     = 3
    }
]

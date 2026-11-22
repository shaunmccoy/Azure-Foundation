
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"

resource_group_name     = "flintstone-lb-rg"
load_balancer_name       = "freds-load-balancer"

frontend_ip_config = {
    MyIpOne = {
        subnet_id           = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/flintstone-lb-rg/providers/Microsoft.Network/virtualNetworks/load_balancer_vnet/subnets/load_balancer_subnet"
        private_ip_address  = "10.0.1.4"
    }
    MyIpTwo = {
        subnet_id           = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/flintstone-lb-rg/providers/Microsoft.Network/virtualNetworks/load_balancer_vnet/subnets/load_balancer_subnet"
        private_ip_address  = "10.0.1.5"
    }
}
backend_address_pool_list = ["backend1", "backend2"]
nat_pool_config = {
    MyNatPool1 = {
        frontend_ip_configuration_name  = "MyIpOne"
        protocol                        = "Tcp"
        frontend_port_start             = 80
        frontend_port_end               = 81
        backend_port                    = 80
    }
}

nat_rule_config = {
    MyNatRule2 = {
        frontend_ip_configuration_name  = "MyIpTwo"
        protocol                        = "Tcp"
        frontend_port                   = 80
        backend_port                    = 80
    }
}

probe_config = {
    MyProbe1 = {
        port                            = 23
        protocol                        = "Tcp"
        request_path                    = ""
    }
}

lb_rule_config = {
    LbRule1 = {
        frontend_ip_configuration_name  = "MyIpTwo"
        protocol                        = "Tcp"
        frontend_port                   = 23
        backend_address_pool_name       = "backend2"
        backend_port                    = 23
        probe_name                      = "MyProbe1"
    }
}

location            = "centralus"

log_analytics_workspace_id = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.OperationalInsights/workspaces/example-lab-log-analytics-workspace"

tags = {
    first = "fred"
    second = "flintstone"
    }
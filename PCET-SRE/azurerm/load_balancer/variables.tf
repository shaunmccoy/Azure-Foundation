
variable load_balancer_name {}
variable location {}
variable resource_group_name {}
variable tags { type = map(string) }

variable frontend_ip_config {
    default = {}
    type = map(object({
        subnet_id           = string
        private_ip_address  = string
    }))
}
variable backend_address_pool_list { 
    type = list(string) 
    default = []
}
variable nat_pool_config {
    default = {}
    type = map(object({
        frontend_ip_configuration_name  = string
        protocol                        = string
        frontend_port_start             = number
        frontend_port_end               = number
        backend_port                    = number
    }))
}

# Variables that are optional and can be added later if needed: idle_timeout_in_minutes, enable_floating_ip, enable_tcp_reset
variable nat_rule_config {
    default = {}
    type = map(object({
        frontend_ip_configuration_name  = string
        protocol                        = string
        frontend_port                   = number
        backend_port                    = number
    }))
}

# Variables that are optional and can be added later if needed: interval_in_seconds, number_of_probes
variable probe_config {
    default = {}
    type = map(object({
        port                            = number
        protocol                        = string
        request_path                    = string
    }))
}

# Variables that are optional and can be added later if needed: enable_floating_ip, idle_timeout_in_minutes, load_distribution, disable_outbound_snat, enable_tcp_reset
variable lb_rule_config {
    default = {}
    type = map(object({
        frontend_ip_configuration_name  = string
        protocol                        = string
        frontend_port                   = number
        backend_address_pool_name       = string
        backend_port                    = number
        probe_name                      = string
    }))
}

variable log_analytics_workspace_id { default = "" }
variable log_analytics_retention_days { default = 0}
variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable diagnostic_log_category_list {
    default = ["LoadBalancerAlertEvent"
        , "LoadBalancerProbeHealthStatus"
        ]
}
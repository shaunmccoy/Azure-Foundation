variable account_name {}
variable account_sku_name { default = "Basic" }

variable location {}
variable resource_group_name {}
variable tags { 
    type    = map(string) 
    default = {}
}

variable worker_scale_set_name { }
variable worker_scale_set_sku { default = "Standard_A2_v2" }
variable worker_scale_set_vm_count { 
    type    = number
    default = 1 
}
variable worker_admin_username { default = "azdoadmin"}
variable worker_admin_public_key { }
variable worker_scale_set_nic_name { }
variable worker_subnet_id { }
variable hybrid_worker_group_name {}
variable worker_managed_id_list {
    type = list(string)
    default = []
}

variable http_proxy { default = "http://proxy.example.com:80/" }
variable https_proxy { default = "http://proxy.example.com:80/" }
variable no_proxy_udr { default = "" }

variable log_analytics_workspace_name { }
variable log_analytics_workspace_sku {default = "Free"}
variable log_analytics_retention_days { default = 7 }
variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable diagnostics_retention_days { default = 0 }
variable diagnostic_log_category_list {
    default = ["DscNodeStatus"
        , "JobLogs"
        , "JobStreams"
        ]
}
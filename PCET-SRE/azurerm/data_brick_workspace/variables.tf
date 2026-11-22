variable data_brick_workspace_name {}
variable data_brick_workplace_sku { default = "premium"}
variable location {}
variable resource_group_name {}
variable managed_resource_group_name { default = null }

variable virtual_network_id {}
variable public_subnet_name {}
variable private_subnet_name {}

variable log_analytics_workspace_id { default = ""}
variable log_analytics_retention_days { default = 0 }

variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable diagnostic_log_category_list {
    default = ["dbfs"
        , "clusters"
        , "accounts"
        , "jobs"
        , "notebook"
        , "ssh"
        , "workspace"
        , "secrets"
        , "sqlPermissions"
        , "instancePools"
    ]
}

variable tags { 
    type = map(string) 
    default = {}
    }
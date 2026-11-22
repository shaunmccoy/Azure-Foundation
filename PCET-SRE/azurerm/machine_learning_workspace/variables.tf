variable deployment_name {}
variable secure_dependent_resources { type    = bool }

variable machine_learning_workspace_name {}
variable machine_learning_workplace_sku { default = "Basic"}
variable workspace_private_endpoint_name {}

variable key_vault_name {}
variable key_vault_disk_soft_delete_days { 
    type    = number 
    default = 7
}
variable key_vault_disk_purge_protection { 
    type    = bool 
    default = true
}
variable key_vault_sku { default = "standard"}

variable storage_account_name {}
variable storage_account_account_tier { default = "Standard"}
variable storage_account_account_replication { default = "GRS"}

variable container_registry_name {}
variable container_registry_sku { default = "Premium"}
variable container_registry_geo_locations { default = ["centralus", "eastus2"] }

variable app_insights_name {}
variable app_insights_app_type { default = "web"}

variable vnet_name {}
variable vnet_rg_name {}
variable subnet_name {}

variable location {}
variable resource_group_name {}

variable log_analytics_workspace_id { default = ""}
variable log_analytics_retention_days { default = 0 }

variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable machine_learning_diagnostic_log_category_list {
    default = ["AmlComputeClusterEvent"
        , "AmlComputeClusterNodeEvent"
        , "AmlComputeJobEvent"
        , "AmlComputeCpuGpuUtilization"
        , "AmlRunStatusChangedEvent"
    ]
}

variable vault_diagnostic_log_category_list {
    default = ["AuditEvent"
    ]
}

variable registry_diagnostic_log_category_list {
    default = ["ContainerRegistryRepositoryEvents"
        , "ContainerRegistryLoginEvents"
    ]
}

variable tags { 
    type = map(string) 
    default = {}
    }
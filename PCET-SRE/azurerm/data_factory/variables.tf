variable data_factory_name {}
variable subscription_id {}
variable location {}
variable resource_group_name {}
variable log_analytics_workspace_id { default = ""}
variable log_analytics_retention_days { default = 0}
variable subnet_id {}
variable private_endpoint_name {}

variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable diagnostic_log_category_list {
    default = ["ActivityRuns"
        , "PipelineRuns"
        , "TriggerRuns"
        , "SSISPackageEventMessages"
        , "SSISPackageExecutableStatistics"
        , "SSISPackageEventMessageContext"
        , "SSISPackageExecutionComponentPhases"
        , "SSISPackageExecutionDataStatistics"
        , "SSISIntegrationRuntimeLogs"
        ]
}

variable deployment_name {}

variable tags { 
    type = map(string) 
    default = {}
    }
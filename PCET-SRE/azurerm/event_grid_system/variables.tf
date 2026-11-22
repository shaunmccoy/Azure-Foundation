variable event_grid_name {}

variable event_source_resource_id {}
variable event_source_topic_type {}

variable subscription_id {}
variable location {}
variable resource_group_name {}
variable log_analytics_workspace_id { default = ""}
variable log_analytics_retention_days { default = 0}

variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}

variable deployment_name {}

variable tags { 
    type = map(string) 
    default = {}
    }
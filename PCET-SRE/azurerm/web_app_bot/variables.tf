
variable bot_name {}
variable resource_group_name {}
variable location {}
variable bot_sku { default = "S1"}
variable bot_application_id {}
variable bot_endpoint {}

variable log_analytics_workspace_id { default = ""}
variable log_analytics_retention_days { default = 0}
variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable diagnostic_log_category_list {
    default = ["BotRequest"
    ]
}

variable tags {}
variable global_app_ind { 
    type = bool 
    default = true
}
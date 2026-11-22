variable runbook_name {}
variable location {}
variable resource_group_name {}
variable "tags" { type = map(string) }

variable account_name {}
variable log_verbose { 
    type    = bool
    default = true
}
variable log_progress {
    type    = bool
    default = true
}
variable runbook_description { default = ""}
variable runbook_type {}
variable runbook_content {}

variable "schedule_config" {
    default = {}
}

variable hybrid_worker_group_name { default = "" }
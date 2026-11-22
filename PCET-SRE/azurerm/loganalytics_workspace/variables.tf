variable resource_group_name {
}
variable location {
}
variable log_analytics_workspace_name { 
}
variable sku { }        
variable retention_in_days { }
variable tags {

}

variable solution_config {
    default = {}
    type = map(object({
        publisher  = string
        product    = string
    }))
}

variable "public_ip_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "allocation_method" {
    description = "Allowed values are Static, Dynamic"
    default     = "Static"
}
variable "public_ip_sku" {
    description = "Allowed values are Standard, Basic"
    default     = "Standard"
}
variable "log_analytics_workspace_id" {}



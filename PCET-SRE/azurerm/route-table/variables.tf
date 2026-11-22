variable "resource_group_name" {
    description = "Route table Resource Group"
}

variable "route_table_name" {
    description = "Route table name"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     =  {
  }
}

variable "route_table" {
  description = "(Required) route table object to be created"
}

variable "next_hop_in_dynamic_private_ip" {
  description = "(Optional) dynamically passing private ip address which is an output of another tf resource or module, e.g. azure firewall"
  type        = string
  default     = null
}
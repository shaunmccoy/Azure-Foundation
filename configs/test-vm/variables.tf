variable "subnet_id" {
  description = "Subnet the test VMs attach to. Point it at whichever subnet's connectivity is being tested."
  type        = string
}

variable "vm_size" {
  description = "VM size for both test VMs."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Local administrator account on both test VMs."
  type        = string
  default     = "azadmin"
}

variable "http_proxy" {
  description = "Optional HTTP proxy URL configured on the Linux test VM."
  type        = string
  default     = null
}

variable "https_proxy" {
  description = "Optional HTTPS proxy URL configured on the Linux test VM."
  type        = string
  default     = null
}

variable "cognitive_service" {
  description = <<-EOT
    Optional Azure AI services account, reachable only through a private endpoint, for testing
    private-link name resolution and routing. Null skips it. The private endpoint goes in
    `private_endpoint_subnet_name` of the given virtual network; pass the privatelink
    cognitiveservices DNS zone ID to have its record registered.
  EOT
  type = object({
    kind                         = optional(string, "CognitiveServices")
    sku_name                     = optional(string, "S0")
    vnet_name                    = string
    vnet_resource_group_name     = string
    private_endpoint_subnet_name = optional(string, "PrivateLink")
    private_dns_zone_ids         = optional(list(string), [])
  })
  default = null
}

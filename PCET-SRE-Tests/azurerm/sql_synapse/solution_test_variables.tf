variable "subscription_id" {
  default = "10000000-0000-0000-0000-000000000003"
}

variable "tenant_id" {
  default = ""
}

variable "synapse_sql_pool_name" {
  default = "synapsesqlpool1"
}

variable "managed_private_endpoint_name" {
  description = "Specifies the name which should be used for this Managed Private Endpoint. Changing this forces a new resource to be created."
  default     = "pendpoint1"
}
variable "target_resource_id" {
  description = "(Required) The ID of the Private Link Enabled Remote Resource which this Synapse Private Endpoint should be connected to. Changing this forces a new resource to be created."
  default     = "remoteresource1"
}

variable "subresource_name" {
  description = "(Required) Specifies the sub resource name which the Synapse Private Endpoint is able to connect to. Changing this forces a new resource to be created."
  default     = "subresource1"
}

variable "sql_administrator_login" {
  description = "(Required for synapse_workspace) Specifies The Login Name of the SQL administrator. Changing this forces a new resource to be created."
  default     = ""
}

variable "role_name" {
  description = "(Required) The Role Name of the Synapse Built-In Role. Changing this forces a new resource to be created. Available roles are Workspace Admin, Apache Spark Admin, and Sql Admin"
  default     = "Workspace Admin"
}

variable "principal_id" {
  description = "(Required) The ID of the Principal (User, Group or Service Principal) to assign the Synapse Role Definition to. Changing this forces a new resource to be created."
  default     = ""
}

variable "tags" {
  default = {}
}

/*variable aad_admin_login {
    default = "admin@example.com"
    description = "The login name of the Azure AD Administrator of this Synapse Workspace."
}

variable object_id {
    description = "The object id of the Azure AD Administrator of this Synapse Workspace."
    default = "10000000-0000-0000-0000-00000000000a"
}*/

variable "sql_pool_sku_name" {
  default = "standard_LRS"
}

variable "log_analytics_workspace_id" { default = "" }

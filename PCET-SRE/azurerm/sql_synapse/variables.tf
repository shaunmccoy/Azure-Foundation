
variable "resource_group_name" {}
variable "location" {}
variable "tags" { default = {} }

variable "synapse_workspace_name" {}
variable "storage_account_name" {}
variable "storage_data_lake_gen2_filesystem_name" {}

variable "synapse_sql_pool_name" { default = null }
variable "sql_pool_sku_name" { default = "DW100c" }
variable "sql_administrator_login" { default = "azdoadmin" }
variable "sql_administrator_login_password" {
  description = "The Password associated with the sql_administrator_login for the SQL administrator."
  default     = null
}

variable "log_analytics_workspace_id" { default = "" }
variable "log_analytics_retention_days" { default = 0 }

variable "diagnostics_name" { default = "LOGANAYTICS-DIAGNOSTICS" }
variable "synapse_diagnostic_log_category_list" {
  default = ["SynapseRbacOperations"
    , "GatewayApiRequests"
    , "SQLSecurityAuditEvents"
    , "BuiltinSqlReqsEnded"
    , "IntegrationPipelineRuns"
    , "IntegrationActivityRuns"
    , "IntegrationTriggerRuns"
  ]
}

variable "managed_private_endpoint_name" {
  description = "Specifies the name which should be used for this Managed Private Endpoint. Changing this forces a new resource to be created."
}

variable "target_resource_id" {
  description = "(Required) The ID of the Private Link Enabled Remote Resource which this Synapse Private Endpoint should be connected to. Changing this forces a new resource to be created."
}

variable "subresource_name" {
  description = "(Required) Specifies the sub resource name which the Synapse Private Endpoint is able to connect to. Changing this forces a new resource to be created."
}

variable "synapse_sql_pool_name" {
  default = null
}

variable "sql_administrator_login" {
  description = "(Required for synapse_workspace) Specifies The Login Name of the SQL administrator. Changing this forces a new resource to be created."
  default     = "admin"
}

variable "role_name" {
  description = "(Required) The Role Name of the Synapse Built-In Role. Changing this forces a new resource to be created. Available roles are Workspace Admin, Apache Spark Admin, and Sql Admin"
  default     = "Workspace Admin"
}

variable "principal_id" {
  description = "(Required) The ID of the Principal (User, Group or Service Principal) to assign the Synapse Role Definition to. Changing this forces a new resource to be created."
  default     = "10000000-0000-0000-0000-00000000000a"
}

/*variable pool_sku_name {
    description = "(Required for Sql_Pool) Specifies the SKU Name for this Synapse Sql Pool. Possible values are DW100c, DW200c, DW300c, DW400c, DW500c, DW1000c, DW1500c, DW2000c, DW2500c, DW3000c, DW5000c, DW6000c, DW7500c, DW10000c, DW15000c or DW30000c."
    default = "DW100c"
  }*/

variable "tags" {
  default = {}
}

/*variable aad_admin_login {
    default = "example"
    description = "The login name of the Azure AD Administrator of this Synapse Workspace."
}

variable object_id {
    description = "The object id of the Azure AD Administrator of this Synapse Workspace."
    default = "10000000-0000-0000-0000-00000000000a"
}*/

variable "sku_name" {
  default = "DW100c"
}

variable "log_analytics_workspace_id" { default = "" }
variable "log_analytics_retention_days" { default = 0 }

variable "diagnostics_name" { default = "LOGANAYTICS-DIAGNOSTICS" }
variable "diagnostic_log_category_list" {
  default = ["SynapseRbacOperations"
    , "GatewayApiRequests"
    , "SQLSecurityAuditEvents"
    , "BuiltinSqlReqsEnded"
    , "IntegrationPipelineRuns"
    , "IntegrationActivityRuns"
    , "IntegrationTriggerRuns"
  ]
}

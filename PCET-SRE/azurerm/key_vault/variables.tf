variable name {
  description = "Specifies the name of the Key Vault. Changing this forces a new resource to be created."
}

variable location {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable resource_group_name {
  description = "The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created."
}

variable sku_name {
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  default     = "standard"
}

variable tenant_id {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Changing this forces a new resource to be created."
  default = ""      # Defaults to tenent used during execution.
}

variable object_id_list {
  description = "List of object IDs of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Changing this forces a new resource to be created."
  default = []      # Defaults to object used during execution.
}

variable application_id {default = null}
variable enabled_for_deployment {default = false}
variable enabled_for_template_deployment {default = false}
variable enable_rbac_authorization {default = false}
variable purge_protection_enabled {default = false}
variable soft_delete_retention_days {default = 90}
variable secure_resources { 
  description = "Indicates if the ky_vault will be secured by private link"
  type    = bool 
  default = true
}
variable subnet_id {
  description = "Indicates where private link will be established."
}

variable log_analytics_workspace_id { default = ""}
variable log_analytics_retention_days { default = 0 }

variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable diagnostic_log_category_list {
    default = ["AuditEvent"
    ]
}


variable certificate_permissions {
  description = "List of certificate permissions, must be one or more from the following: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers and update."
  default     = []
}

variable key_permissions {
  description = "List of key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey."
  default     = ["get"]

}

variable secret_permissions {
  description = "List of secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set."
  default     = ["get"]

}

variable storage_permissions {
  description = "List of storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update."
  default     = []
}

variable tags {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
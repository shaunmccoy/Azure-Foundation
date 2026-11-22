variable resource_group_name {
  description="The name of the resource group in which KeyVault will be created"
}
variable location {
  description="Specifies the supported Azure location where Keyvault will be created."
}

variable kv_name {
  default = "kv_name"
  description = "(Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created."
}
variable soft_delete_retention_days {
  description ="Number of days soft deleted data will be retained"
}
variable tags {
  description="The tags associated with this application."
}
variable soft_delete_enabled {
  description ="indicate whether softdelete should be enabled"
}
variable tenant_id {
  description ="Tenenat id"
}
variable sku_name {
  description ="Select Standard or Premium SKU"
  default = "Premium"
}
variable enabled_for_template_deployment {
  type        = string
  description = "Allow Azure Resource Manager to retrieve secrets from the Azure Key Vault"
  default     = "true"
}
variable enabled_for_disk_encryption  {
  type        = string
  description = "Allow Azure Disk Encryption to retrieve secrets from the Azure Key Vault and unwrap keys" 
  default     = "true"
}
variable enabled_for_deployment  {
  type        = string
  description = "Allow Azure Virtual Machines to retrieve certificates stored as secrets from the Azure Key Vault"
  default     = "true"
}

variable keyvault_key_full_permissions {
  type = list(string)
  description = "List of full key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey."
  default     = [ "backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey","update", "verify", "wrapKey" ]
}
variable keyvault_secret_full_permissions {
  type = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = [ "backup", "delete", "get", "list", "purge", "recover", "restore", "set" ]
}
variable keyvault_certificate_full_permissions {
  type = list(string)
  description = "List of full storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = [ "backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "purge", "recover", "restore", "setissuers", "update"]
}
variable keyvault_storage_full_permissions {
 type        = list(string)
  description = "List of full storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = [ "backup", "delete", "deletesas", "get", "getsas", "list", "listsas", "purge", "recover", "regeneratekey", "restore", "set", "setsas", "update" ]
}
variable keyvault_key_read_permissions {
  type        = list(string)
  description = "List of read key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey"
  default     = [ "get", "list" ]
}

variable keyvault_secret_read_permissions {
  type        = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = [ "get", "list" ]
} 

variable keyvault_certificate_read_permissions {
  type        = list(string)
  description = "List of full certificate permissions, must be one or more from the following: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers and update"
  default     = [ "get", "getissuers", "list", "listissuers" ]
}
variable keyvault_storage_read_permissions {
  type        = list(string)
  description = "List of read storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = [ "get", "getsas", "list", "listsas" ]
}
variable key_object_id {}
variable policies {
  type = map(object({
    tenant_id               = string
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
    storage_permissions     = list(string)
  }))
  description = "Define a Azure Key Vault access policy"
  default = {}
}

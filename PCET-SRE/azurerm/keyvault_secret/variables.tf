variable key_vault_id {
    description = "The ID of the Key Vault where the Secret should be created."
}
/*variable content_type {
  default = "kv_name"
  description = "Specifies the content type for the Key Vault Secret"
}
variable not_before_date {
  description ="Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z')."
}
variable expiration_date {
  description="Expiration UTC datetime (Y-m-d'T'H:M:S'Z')."
}
*/
variable tags {
  description ="The tags associated with this application."
}
variable "keyvault_secrets" {
  type = map(object({
    value = string
  }))
  description = "Define Azure Key Vault secrets"
  default     = {}
}
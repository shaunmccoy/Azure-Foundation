variable tenant_id {}
variable subscription_id {}
variable resource_group_name {}
variable deployment_name {}
variable data_lake_name {}
variable location {}
variable account_tier {}
variable account_replication_type {}
variable account_kind {}
variable storage_account_name {}
variable is_hns_enabled {}
variable private_endpoint_name {}
variable tags {}
variable secure_dependent_resources {
  default     = false
  type        = bool 
  }

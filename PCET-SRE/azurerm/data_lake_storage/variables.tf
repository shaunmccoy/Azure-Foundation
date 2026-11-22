
variable resource_group_name { description = " This is resource group name for data lake" }
variable data_lake_name { description = " This is data lake name parameter for data lake" }
variable storage_account_name { description = " This is data lake storage account name parameter for data lake" }
variable location { description = " This is resource group name parameter for data lake" }
variable account_tier { description = " This is account tier parameter for data lake" }
variable account_replication_type { description = " This is replicaton type parameter for data lake" }
variable account_kind { description = " This is storage accoutn kind parameter for data lake" }
variable is_hns_enabled { description = " This is HNS enabled for for data lake" }
variable subnet_id {}
variable private_endpoint_name {}
variable secure_dependent_resources { 
  default     = false
  type        = bool 
  }
variable tags { 
    type = map(string) 
    default = {}
    }

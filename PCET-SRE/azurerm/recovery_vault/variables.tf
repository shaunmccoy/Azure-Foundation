
variable vault_name {}
variable vault_sku {default = "Standard"}
variable soft_delete_enabled {
    type = bool
    default = true
}

variable location {}
variable resource_group_name {}
variable tags { type = map(string) }

/*variable frontend_ip_config {
    default = {}
    type = map(object({
        subnet_id           = string
        private_ip_address  = string
    }))
}*/

variable log_analytics_workspace_id { default = "" }
variable log_analytics_retention_days { default = 0}
variable diagnostics_name { default = "LOGANAYTICS-DIAGNOSTICS"}
variable diagnostic_log_category_list {
    default = ["AddonAzureBackupAlerts",
        "AddonAzureBackupJobs",
        "AddonAzureBackupPolicy",
        "AddonAzureBackupProtectedInstance",
        "AddonAzureBackupStorage",
        "AzureBackupReport",
        "AzureSiteRecoveryEvents",
        "AzureSiteRecoveryJobs",
        "AzureSiteRecoveryProtectedDiskDataChurn",
        "AzureSiteRecoveryRecoveryPoints",
        "AzureSiteRecoveryReplicatedItems",
        "AzureSiteRecoveryReplicationDataUploadRate",
        "AzureSiteRecoveryReplicationStats",
        "CoreAzureBackup"
        ]
}
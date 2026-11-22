variable storage_account_name {
  description="Specifies the name of the storage account."
}
variable resource_group_name {
  description="The name of the resource group in which to create the storage account."
}
variable location {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}
variable account_tier {
  description="Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Standard and Premium."
}
variable account_kind {
  description="Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Standard and Premium."
}
variable access_tier {
  description="Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Standard and Premium."
}
variable tags {
  description="The tags associated with this application."
}
variable replication_type {
  description="Specify the replication type of data"
}

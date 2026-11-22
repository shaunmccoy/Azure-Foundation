
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000004"
storage_account_name = "ntdlstorageacc"
resource_group_name     = "test-rg"
deployment_name         = "data-lake-pcet"
data_lake_name       = "data-lake"
location            = "centralus"
account_tier             = "Standard"
account_replication_type = "LRS"
account_kind             = "StorageV2"
is_hns_enabled = "true"
private_endpoint_name = "data_lake_epn"
secure_dependent_resources = false
tags = {
    first = "NT"
    second = "Example"
    }
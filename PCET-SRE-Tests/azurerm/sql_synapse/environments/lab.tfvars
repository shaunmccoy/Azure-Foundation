
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000003"
location            = "centralus"

resource_group_name     = "example_test_rg"
storage_account_name    = "examplesynapsetestlab"
storage_data_lake_gen2_filesystem_name = "exampledatalaketestlab"
synapse_workspace_name = "examplesynapseworkspace"
synapse_sql_pool_name = "example_sql_pool"


/*
solution_config = {
    ContainerInsights = {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}
*/

tags = {
    first = "mozart"
    second = "example"
    }
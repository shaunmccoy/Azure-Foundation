
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"
location            = "centralus"

resource_group_name     = "example_test_rg"
storage_account_name    = "examplesynapsetestlab"
storage_data_lake_gen2_filesystem_name = "exampledatalaketestlab"
synapse_workspace_name = "examplesynapseworkspace"
synapse_sql_pool_name = "example_sql_pool"

log_analytics_workspace_id = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.OperationalInsights/workspaces/example-lab-log-analytics-workspace"

tags = {
    first = "mozart"
    second = "example"
    }
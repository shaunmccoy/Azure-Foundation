
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"
location            = "centralus"

resource_group_name     = "flintstone-key-vault-rg"
vault_name              = "FredsTestKeyVault"

log_analytics_workspace_id = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.OperationalInsights/workspaces/example-lab-log-analytics-workspace"

tags = {
    first   = "fred"
    second  = "flintstone"
    }
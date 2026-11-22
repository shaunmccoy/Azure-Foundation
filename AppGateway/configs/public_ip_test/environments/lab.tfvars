environment         = "ExampleLab"
resource_group_name = "example_stgact_rg"
location            = "centralus"
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"

log_analytics_workspace_id = "/subscriptions/10000000-0000-0000-0000-000000000002/resourcegroups/example_stgact_rg/providers/microsoft.operationalinsights/workspaces/example-lab-log-analytics-workspace"

environment_tags = {
    "nt:environment" = "Lab"
}
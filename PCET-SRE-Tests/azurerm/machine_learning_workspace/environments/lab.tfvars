
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"

resource_group_name     = "flintstone-machine-learning-rg"
deployment_name         = "flintstone-machine-learning-test"
machine_learning_workspace_name       = "freds-machine-learning"
private_endpoint_name   = "freds-machine-learning-private-endpoint"

location            = "centralus"
#devops_account_name = "example-org"
#devops_project_name = "example-project"
#devops_repo_name    = "PCET-SRE"
#devops_branch_name  = "master"

log_analytics_workspace_id = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.OperationalInsights/workspaces/example-lab-log-analytics-workspace"

tags = {
    first = "fred"
    second = "flintstone"
    }

tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"
location            = "centralus"

resource_group_name     = "flintstone-automation-rg"
account_name            = "FredAutomationAccount"
runbook_name            = "FredTestRunbook"
runbook_description     = "Freds test runbook"
runbook_source_uri      = "https://dev.azure.com/example-org/example-project/_apis/sourceProviders/TfsGit/filecontents?repository=PCET-SRE-Tests&path=%2Fazurerm%2Fautomation_environment%2Frunbook-test.PS1&commitOrBranch=main&api-version=5.0-preview.1"
runbook_type            = "PowerShell"

worker_managed_id_list = ["/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-test-managed-id"]

schedule_config = {
    weekly-schedule = {
        frequency = "Week"
        week_days = ["Monday"]

        parameters = {                      # Optional parameters for the runbook for this schedule
            flintstone-name = "Fred"
            barney-name = "Barney"
        }
    }
    monthly-schedule = {
        frequency = "Month"
        month_days = [15, -1]
    }
}

tags = {
    first   = "fred"
    second  = "flintstone"
    }
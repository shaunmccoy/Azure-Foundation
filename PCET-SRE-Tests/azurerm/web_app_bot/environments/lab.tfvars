
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"
location            = "centralus"

resource_group_name     = "flintstone-bot-rg"
bot_name                = "BarneyBotHandle"
bot_application_id      = "10000000-0000-0000-0000-00000000000b"
bot_endpoint = "https://example-bot.azurewebsites.net/api/messages"

log_analytics_workspace_id = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.OperationalInsights/workspaces/example-lab-log-analytics-workspace"

tags = {
    first   = "fred"
    second  = "flintstone"
    }
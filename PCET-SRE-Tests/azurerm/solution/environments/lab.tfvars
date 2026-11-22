
tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"
location            = "centralus"

resource_group_name     = "flintstone-log-rg"
log_analytics_workspace_name       = "freds-log-analytics"

solution_config = {
    SQLAdvancedThreatProtection = {
        publisher = "Microsoft"
        product   = "OMSGallery/SQLAdvancedThreatProtection"
    }
    SQLVulnerabilityAssessment = {
        publisher = "Microsoft"
        product   = "OMSGallery/SQLVulnerabilityAssessment"
    }
}

/*
solution_config = {
    ContainerInsights = {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}
*/

tags = {
    first = "fred"
    second = "flintstone"
    }

tenant_id           = "10000000-0000-0000-0000-000000000001"
subscription_id     = "10000000-0000-0000-0000-000000000002"

resource_group_name         = "flintstone-data-brickrg"
data_brick_workspace_name   = "freds-data-brick-workspace"

location            = "centralus"

log_analytics_workspace_id = "/subscriptions/10000000-0000-0000-0000-000000000002/resourceGroups/example_stgact_rg/providers/Microsoft.OperationalInsights/workspaces/example-lab-log-analytics-workspace"

# From https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr
databricks_internet_cidr_list = [
    "40.70.58.221/32"           # Web App Central US
    , "20.41.4.113/32"          # Web App Central US
    , "52.247.0.200/32"         # SCC Relay Central US -- tunnel.eastus2.azuredatabricks.net
    , "13.86.58.215/32"         # SCC Relay Central US -- tunnel.centralusc2.azuredatabricks.net
    , "52.182.136.38/32"        # Metastore Central US -- consolidated-centralus-prod-metastore.mysql.database.azure.com
    , "13.67.215.62/32"         # Metastore Central US -- consolidated-centralus-prod-metastore-addl-1.mysql.database.azure.com
                                # Metastore Central US -- consolidated-centralusc2-prod-metastore-0.mysql.database.azure.com
                                # Artifact Blob Central US -- dbartifactsprodcentralus.blob.core.windows.net (Does not resolve)
    , "20.60.30.68/32"          # Artifact Blob Central US -- arprodcusa1.blob.core.windows.net
    , "20.38.122.68/32"         # Artifact Blob Central US -- arprodcusa2.blob.core.windows.net
    , "20.150.95.132/32"        # Artifact Blob Central US -- arprodcusa3.blob.core.windows.net
    , "52.239.177.100/32"       # Artifact Blob Central US -- arprodcusa4.blob.core.windows.net
    , "20.150.95.4/32"          # Artifact Blob Central US -- arprodcusa5.blob.core.windows.net
#    , "20.150.95.4/32"          # Artifact Blob Central US -- arprodcusa6.blob.core.windows.net -- dupe in this region
    , "20.38.104.100/32"        # Artifact Blob Central US -- dbartifactsprodscus.blob.core.windows.net
    , "20.150.34.228/32"        # LOB Blob Central US -- dblogprodwestus.blob.core.windows.net
    , "20.150.77.4/32"          # LOB Blob Central US -- dblogprodcentralus.blob.core.windows.net (address 1)
    , "20.150.89.68/32"         # LOB Blob Central US -- dblogprodcentralus.blob.core.windows.net (address 2)
    , "20.150.63.100/32"        # LOB Blob Central US -- dblogprodcentralus.blob.core.windows.net (address 3)
    , "40.112.242.0/32"         # Event Hub Central US -- prod-westus-observabilityEventHubs.servicebus.windows.net
    , "52.182.138.142/32"       # Event Hub Central US -- prod-centralusc2-observabilityeventhubs.servicebus.windows.net
]

tags = {
    first = "fred"
    second = "flintstone"
    }
variable "signalfx_auth_token" {
 default = "+signalfx_auth_token+"
}

variable "signalfx_api_url" {
  default = "https://api.us1.signalfx.com/v2/integration"
}


variable "name" {
  default = "Azure Terraform Integration"
}

variable "enabled" {
  default = true
}

variable "poll_rate" {
  default = "60"
}

variable "services" {
  type    = list
  default = ["microsoft.analysisservices/servers", "microsoft.apimanagement/service", "microsoft.automation/automationaccounts", "microsoft.batch/batchaccounts", "microsoft.cache/redis", "microsoft.classiccompute/virtualmachines", "microsoft.cognitiveservices/accounts", "microsoft.compute/virtualmachines", "microsoft.compute/virtualmachinescalesets", "microsoft.compute/virtualmachinescalesets/virtualmachines", "microsoft.containerinstance/containergroups", "microsoft.containerservice/managedclusters", "microsoft.customerinsights/hubs", "microsoft.datafactory", "microsoft.datafactory/datafactories", "microsoft.datafactory/factories", "microsoft.datalakeanalytics/accounts", "microsoft.datalakestore/accounts", "microsoft.dbformysql/servers", "microsoft.dbforpostgresql/servers", "microsoft.devices/elasticpools", "microsoft.devices/elasticpools/iothubtenants", "microsoft.devices/iothubs", "microsoft.documentdb/databaseaccounts", "microsoft.eventhub/namespaces", "microsoft.hdinsight/clusters", "microsoft.keyvault/vaults", "microsoft.locationbasedservices/accounts", "microsoft.network/applicationgateways", "microsoft.network/dnszones", "microsoft.network/expressroutecircuits", "microsoft.network/loadbalancers", "microsoft.network/publicipaddresses", "microsoft.network/trafficmanagerprofiles", "microsoft.network/virtualnetworkgateways", "microsoft.notificationhubs/namespaces/notificationhubs", "microsoft.powerbidedicated/capacities", "microsoft.relay/namespaces", "microsoft.search/searchservices", "microsoft.servicebus/namespaces", "microsoft.sql/servers", "microsoft.sql/servers/databases", "microsoft.sql/servers/elasticpools", "microsoft.storage/storageaccounts", "microsoft.storage/storageaccounts/blobservices", "microsoft.storage/storageaccounts/fileservices", "microsoft.storage/storageaccounts/queueservices", "microsoft.storage/storageaccounts/tableservices", "microsoft.streamanalytics/streamingjobs", "microsoft.web", "microsoft.web/hostingenvironments/multirolepools", "microsoft.web/hostingenvironments/workerpools", "microsoft.web/serverfarms", "microsoft.web/sites/slots"]

}

variable "secret_key" {
  default = "+secret_key+"
 }

variable "app_id" {
  default = "10000000-0000-0000-0000-000000000007"
}

variable "object_id" {
  default = "10000000-0000-0000-0000-000000000008"
}

variable "subscriptions" {
  type    = list
  default = +subscriptions+
}

variable "role" {
  type        = string
  default     = "Monitoring Reader"
  description = "The name of a role for the service principal."
}

locals {
  scopes = length(var.subscriptions) > 0 ? var.subscriptions : [data.azurerm_subscription.main.id]
}

variable "tenant_id" {
  default = "00000000-0000-0000-0000-000000000000"
}
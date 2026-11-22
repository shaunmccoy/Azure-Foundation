
variable resource_group_name {
  description = "Specify here the name of the resource group under which Cluster will be created"
}
variable location {
  description = "This is location where AKS Cluster will be created"
}
variable tenant_id {
  description = "Subscription Tenant Id"
}
variable aks_subnet_name {
  description = "Name of the Subnet where AKS Cluster will be created"
}
variable aks_vnet_name {
   description = "Name of the Virtual network where AKS cluster will be created"
}
variable aks_vnet_resource_group_name {
  description = "Resource group of Virtual network where AKS cluster will be created"
}
variable tags {
  default = {}
  description="The name of the tags to be applied on AKS"
}
variable client_app_id {
   description = "This is client id of the Service Principal"
}
variable client_app_secret{
  description = "client app secret incase RBAC is done using Service Principal approach"
}
variable server_app_id {
  description ="This is the id of Service principal created for server"
}
variable server_app_secret {
  description = "Server app secret incase RBAC is done using Service Principal approach"
}
variable node_count {
  description = "Specify here the total number of nodes required in the cluster"
}
variable nodepool_name {
  description="Specify here the name of the node pool"
}
variable enable_auto_scaling {
  description="Specify if cluster automscaling should be enabled e.g. true or false"
}
variable ssh_public_key {
   description = "Specify here the ssh public key for linux instances"
}
variable dns_prefix {
 description = "DNS Prefix of the Cluster"
}
variable cluster_name {
  description="Specify here name of the cluster"
}

variable log_analytics_workspace_name {
   description = "Specify here the name of the log analyttics workspace"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  description ="Specify here the name of the log Aalytics workspace location"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
  description = "Specify here the name of the workspace SKU"
}
variable node_admin_username {
  description = "User Name of the linux box, for e.g. ubuntu"
}
variable node_vm_size {
  description ="Size of the node VM for e.g. Standard_D2_v2"
}
variable kubernetes_version {
  description ="Specify here Kubernetes Version to be used for creation for e.g. 1.17.9"
}
variable private_cluster_enabled {
  description ="Parameter to define if Cluster has to be completely Private, in the bank in most of the cases it should be True"
}

variable network_profile_network_plugin {
  description ="Specify the network plug-in to be used for e.g. kubenet"
}
variable network_profile_dns_service_ip {
  description = "Specify the DNS service ip, usually it will be 10th ip of service cidr block for e.g. 10.3.0.10"
}
variable network_profile_docker_bridge_cidr {
  description ="This is docker bridge address CIDR block for e.g. 172.17.0.1/16"
}
variable network_profile_docker_pod_cidr {
  description ="POD CIDR block for e.g. 172.16.0.0/16"
}
variable network_profile_docker_service_cidr {
  description="Service CIDR block for e.g. 10.4.0.0./16"
}
variable network_profile_outbound_type {
  description="The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
}
variable admin_group_object_ids {
  default = []
  description = "List of Object ids of AD groups to access the cluster using admin rights"
}
variable network_policy {
  description ="Specify the network policy here, possible values are Calico and azure, in case of kubenet, mostly it will always be Calico"
}
variable sku_tier {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free"
}

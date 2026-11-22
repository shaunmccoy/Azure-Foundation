
data "azurerm_virtual_network" "aks_vnet" {
  name = var.aks_vnet_name
  resource_group_name = var.aks_vnet_resource_group_name
}
data "azurerm_subnet" "aks_subnet" {
 
  name =  var.aks_subnet_name
  virtual_network_name = var.aks_vnet_name
  resource_group_name = var.aks_vnet_resource_group_name
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = var.location
    resource_group_name = var.resource_group_name 
    
    default_node_pool {
        name            = var.nodepool_name
        node_count      = var.node_count
        vm_size         = var.node_vm_size

        //availability_zones = ["1","2"] // This is not availble in Northcentralus
        enable_auto_scaling = var.enable_auto_scaling
        vnet_subnet_id = data.azurerm_subnet.aks_subnet.id
        max_count     = 15
        max_pods      = 110
        min_count     =  2
    }
   
    dns_prefix          = var.dns_prefix

    auto_scaler_profile {
      # As of now i don't see need of changing these
      balance_similar_node_groups = false
      max_graceful_termination_sec = 600
      scale_down_delay_after_add = "10m"
      scale_down_delay_after_delete = "10s"
      scale_down_delay_after_failure = "3m"
      
      scan_interval = "10s"
      
      scale_down_unneeded = "10m"
      
      scale_down_unready = "20m"
      
      scale_down_utilization_threshold = 0.5
    }
  
    service_principal {
        client_id     = var.client_app_id
        client_secret = var.client_app_secret
    }
    # Managed Identity doesn work with Private Cluster as of yet
  /*  identity {
        type = "SystemAssigned"
    }
  */
    kubernetes_version = var.kubernetes_version
    
    linux_profile {
        admin_username = var.node_admin_username

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }
    network_profile {
        network_plugin      = var.network_profile_network_plugin
        dns_service_ip      = var.network_profile_dns_service_ip   
        docker_bridge_cidr  = var.network_profile_docker_bridge_cidr
        pod_cidr            = var.network_profile_docker_pod_cidr
        service_cidr        = var.network_profile_docker_service_cidr
        outbound_type       = var.network_profile_outbound_type
        network_policy      = var.network_policy
    }
    
    private_cluster_enabled = var.private_cluster_enabled
    
    role_based_access_control  {

      azure_active_directory {
      
        admin_group_object_ids =  var.admin_group_object_ids // This would be Cluster Admin AD group
      
        managed = true
        tenant_id = var.tenant_id

      }

      enabled = true
    }
    sku_tier = var.sku_tier

    //addon_profile {
      //  oms_agent {
      //  enabled                    = true
      //  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
      //  }
      // kube_dashboard {
      //  enabled = var.kube_dashboard 
      // }
    //}

    tags = var.tags
}

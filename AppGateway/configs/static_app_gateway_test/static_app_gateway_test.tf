
/*
    Prerequisites:

    An application subnet with no NSG needs to be defined for exclusive use by the Application Gateway
    A public IP needs to exist that will be consumed by the Application Gateway
 */

module "APPLICATION_GATEWAY" {
  source                = "../../modules/application_gateway"

  app_gateway_name      = "${var.environment}TestAppGateway"
  resource_group_name   = var.resource_group_name
  location              = var.location

  gateway_ip_configuration_list     = var.gateway_ip_configuration_list
  frontend_ip_configuration_list    = var.frontend_ip_configuration_list
  frontend_port_list                = var.frontend_port_list
  backend_address_pool_list         = var.backend_address_pool_list
  backend_http_setting_list         = var.backend_http_setting_list

  http_listener_list                = var.http_listener_list
  request_routing_rule_list         = var.request_routing_rule_list
  health_probe_list                 = var.health_probe_list

}
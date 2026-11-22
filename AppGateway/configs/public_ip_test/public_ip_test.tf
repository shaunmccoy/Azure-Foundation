
/*
    Prerequisites:

    An application subnet with no NSG needs to be defined for exclusive use by the Application Gateway
    A public IP needs to exist that will be consumed by the Application Gateway
 */

module "public_ip" {
  source                        = "../../modules/public_ip"

  public_ip_name                = "${var.environment}AppGatewayPublicIp"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  log_analytics_workspace_id    = var.log_analytics_workspace_id

}
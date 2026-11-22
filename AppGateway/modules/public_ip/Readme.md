# Public IP 

This module will define standard public IP along with log diagnostcs that go with it.


## Files

| File Name | Description |
| --- | --- |
| `public_ip_variables.tf` | Module Variables |
| `public_ip_outputs.tf` | Output Variables |
| `public_ip_versions.tf` | Terraform software and provider requirements |
| `public_ip.tf` | Main resource definitions |

## Example Usage
```
module "public_ip" {
  source                        = "../../modules/public_ip"

  public_ip_name                = "${var.environment}AppGatewayPublicIp"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  log_analytics_workspace_id    = var.log_analytics_workspace_id

}

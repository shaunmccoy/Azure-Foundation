# API Management

This module will define a standard API Management resource.

## Files

| File Name | Description |
| --- | --- |
| `variables.tf` | Module Variables |
| `outputs.tf`   | Output Variables |
| `versions.tf`  | Terraform software and provider requirements |
| `main.tf`      | Main resource definitions |

## Example Usage
```
module "api_management" {
  source              = "../../modules/api_management"
  tags                = local.common_tags
  resource_group_name = azurerm_resource_group.api_management.name
  location            = var.location
  name                = "nt${lower(var.env)}hub${lower(local.loc_code)}-APIM"
  publisher_name      = "Example Publisher" # who?
  publisher_email     = "publisher@example.com"          # which email?
  sku_name            = "Developer_1" 
  policy_xml_content  = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
  XML
  application_type = "other"
  virtual_network_type = "External"
  subnet_id = "/subscriptions/FFFF0000-FFFF-0000-FFFF-0000FFFF0000/resourceGroups/example-net-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/APIManagement"
}

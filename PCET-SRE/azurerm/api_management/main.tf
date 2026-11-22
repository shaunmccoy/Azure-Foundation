#
locals {
	subnet_list = var.subnet_id == "" ? [] : [var.subnet_id]
}
#
resource "azurerm_api_management" "api_management" {
  name                  = var.name
  location              = var.location
  tags                  = var.tags
  resource_group_name   = var.resource_group_name
  publisher_name        = var.publisher_name
  publisher_email       = var.publisher_email
  sku_name              = var.sku_name
  virtual_network_type  = var.virtual_network_type
  policy {
    xml_content         = var.policy_xml_content
  }
/*
# XML Content passed through the policy_xml_content var
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
XML
*/
# Only allowing 1 subnet_id to be passsed if a subnet_id is passed
  dynamic "virtual_network_configuration" {
	  for_each=local.subnet_list
    content {
      subnet_id = virtual_network_configuration.value
    }
  }
}

resource "azurerm_application_insights" "apim_appinsights" {
  name                = "${var.name}-APPINSIGHTS"
  tags                = var.tags
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
}

resource "azurerm_api_management_logger" "apim_logger" {
  name                = "${var.name}-LOGGER"
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = var.resource_group_name
  application_insights {
    instrumentation_key = azurerm_application_insights.apim_appinsights.instrumentation_key
  }
}
resource "azurerm_api_management_diagnostic" "apim_diagnostic" {
  identifier               = "applicationinsights"
  resource_group_name      = var.resource_group_name
  api_management_name      = azurerm_api_management.api_management.name
  api_management_logger_id = azurerm_api_management_logger.apim_logger.id
}
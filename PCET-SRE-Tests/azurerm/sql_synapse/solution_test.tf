resource "azurerm_resource_group" "example_rg" {
  name     = "example_rg"
  location = "centralus"
  tags     = var.tags
}

module "sql_synapse" {
  # source                          = "git::https://dev.azure.com/example-org/example-project/_git/PCET-SRE//azurerm/sql_synapse"
  source = "../../../PCET-SRE/azurerm/sql_synapse"

  # synapse_sql_pool_name                  = "synapsepool1"
  subresource_name = var.subresource_name
  /*aad_admin_login                       = var.aad_admin_login */
  managed_private_endpoint_name = var.managed_private_endpoint_name
  role_name                     = var.role_name
  sql_administrator_login       = var.sql_administrator_login
  /*object_id                             = var.object_id*/
  principal_id = var.principal_id

}
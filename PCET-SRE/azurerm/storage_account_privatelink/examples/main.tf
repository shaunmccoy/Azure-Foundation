module "storage_account" {
  source = "../"

  storage_account_name="examplestorageacct"
  resource_group_name= "example-spoke-mgmt-rg"
  location= "northcentralus"
  account_tier= "Standard"
  tla= "AZR"
  business_unit= "INFR"
  cost_center= "0888"
  vnet_name= "example-spoke-vnet"
  vnet_resource_group_name= "example-spoke-net-rg"
  replication_type="LRS"
}

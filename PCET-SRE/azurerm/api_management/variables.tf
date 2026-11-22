variable "resource_group_name" {
  description="The name of the resource group in which to create the API Management."
}

variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "name" {
   description="Name of the API Management resource" 
}

variable "tags" {
   description="Set of common tags to use on the module"
   type=map
}

variable "publisher_name" {
    description="Name of organization publishing this API"
}

variable "publisher_email" {
    description="Email address of publisher of API"
}

variable "sku_name" {
    description="Specific SKU for this build"
}

variable "policy_xml_content" {
    description="Full policy(ies) content"
}

variable "application_type" {
    description="Type of application insight"
}

variable "virtual_network_type" {
    description="API Management Virtual Network Type"
}

variable "subnet_id" {
    description="ID of subnet to anchor API Management to"
    default=""
}
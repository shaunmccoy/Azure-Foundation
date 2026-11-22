variable "location" {
  description="Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "tla" {
  description = "The three letter acronym of the application."
}

variable "business_unit" {
  description = "The business unit associated with this application."
}

variable "Owner" {
  default = ""
}

variable "Geo" {
  default = "Americas"
}

variable "region" {
  type = map(string)

  default = {
    centralus          = "CUS"
    eastus             = "EUS"
    eastus2            = "EU2"
    westus             = "WUS"
    northcentralus     = "NCU"
    southcentralus     = "SCU"
  }
}

variable "env" {
  default = "uat"
}

variable "RG-Count" {
  default = "001"
}


variable "env_code" {
  type = map(string)
  default = {
    prod    = "P"
    dev     = "D"
    uat     = "U"
    nonprod = "X"
    sandbox = "Z"
  }
}

variable "tags" {
  description="The tags associated with this application."
}
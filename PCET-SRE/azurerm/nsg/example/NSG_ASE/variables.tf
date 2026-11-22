variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     =  {
    TLA          = "BFA"
    CostCenter   = "0672"
    BusinessUnit = "CISX"
    Environment  = "Prod"
  }
}

variable "resource_group_name" {
    description = "NSG Resource Group"
    default     = "example0001"
}

variable "ase_subnet_name" {
    description = "ASE subnet"
    default     = "example0001"
}

variable "virtual_network_name" {
    description = "The name of the vnet"
    default     = "example0001"
}

variable "vnet_resource_group_name" {
    description = "The name of the vnet"
    default     = "example0001"
}

variable "nsg_name" {
    description = "NSG Name"
    default     = "example0001"
}

variable "nsg_rules" {
  type = list(object({
    name                        = string
    priority                    = number
    direction                   = string
    access                      = string
    protocol                    = string
    source_port_range           = string
    destination_port_range      = string
    source_address_prefix       = string
    destination_address_prefix  = string
    description                                 = string
    destination_address_prefixes                = list(string)
    destination_application_security_group_ids  = list(string)
    destination_port_ranges                     = list(string)
    source_address_prefixes                     = list(string)
    source_application_security_group_ids       = list(string)
    source_port_ranges                          = list(string)
  }))
  default = [
    {
      name =  "Inbound-management"
      description = "Used to manage ASE from public VIP"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "454-455"
      source_address_prefix= "AppServiceManagement"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 100
      direction= "Inbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []    
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Inbound-load-balancer-keep-alive"     
      description = "Allow communication to ASE from Load Balancer"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "16001"
      source_address_prefix= "AzureLoadBalancer"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 105
      direction= "Inbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Inbound-HTTP"      
      description = "Allow HTTP"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "80"
      source_address_prefix= "10.0.0.0/8"
      destination_address_prefix= "10.100.0.0/16"
      access= "Allow"
      priority= 120
      direction= "Inbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []    
      destination_application_security_group_ids  = []
      source_application_security_group_ids       = []
    },
    {
      name =  "Inbound-HTTPS"     
      description = "Allow HTTPS"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "443"
      source_address_prefix= "10.0.0.0/8"
      destination_address_prefix= "10.100.0.0/16"
      access= "Allow"
      priority= 130
      direction= "Inbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Inbound-FTPS"      
      description = "Allow FTPS"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "990"
      source_address_prefix= "10.0.0.0/8"
      destination_address_prefix= "10.100.0.0/16"
      access= "Allow"
      priority= 150
      direction= "Inbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= [] 
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Inbound-FTP-Data"    
      description = "RDP"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "10001-10020"
      source_address_prefix= "10.0.0.0/8"
      destination_address_prefix= "10.100.0.0/16"
      access= "Allow"
      priority= 160
      direction= "Inbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Inbound-Remote-Debugging"  
      description = "Visual Studio remote debugging"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "4016-4022"
      source_address_prefix= "10.0.0.0/8"
      destination_address_prefix= "10.100.0.0/16"
      access= "Allow"
      priority= 170
      direction= "Inbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Outbound-443"       
      description = "Azure Storage blob"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "443"
      source_address_prefix= "*"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 100
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []  
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Outbound-DB"  
      description = "Database"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "1433"
      source_address_prefix= "*"
      destination_address_prefix= "Sql"
      access= "Allow"
      priority= 110
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Outbound-DNS"       
      description = "DNS"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "53"
      source_address_prefix= "*"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 120
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "ASE-internal-outbound"      
      description = "Azure Storage queue"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "*"
      source_address_prefix= "*"
      destination_address_prefix= "10.100.84.0/24"
      access= "Allow"
      priority= 130
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Outbound-80"  
      description = "Outbound 80"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "80"
      source_address_prefix= "*"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 140
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []  
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "ASE-to-VNET"      
      description = "ASE to VNET"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "*"
      source_address_prefix= "*"
      destination_address_prefix= "10.100.80.0/21"
      access= "Allow"
      priority= 150
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Outbound-NTP"    
      description = "Clock"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "123"
      source_address_prefix= "*"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 160
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
  
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    },
    {
      name =  "Allow_App_Gateway"
      description = "app gateway"
      protocol = "*"
      source_port_range= "*"
      source_address_prefix= "10.100.84.62"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 108
      direction= "Inbound"
      destination_port_range = null
      source_port_ranges= []
      destination_port_ranges= [
          "80",
          "443"
      ]
      source_address_prefixes= []
      destination_address_prefixes= []      
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
        },
    {
      name =  "Port_8000_8500_out"
      description = "Port_8000_8500_out"
      protocol = "*"
      source_port_range= "*"
      destination_port_range= "8000-8500"
      source_address_prefix= "*"
      destination_address_prefix= "*"
      access= "Allow"
      priority= 170
      direction= "Outbound"
      source_port_ranges= []
      destination_port_ranges= []
      source_address_prefixes= []
      destination_address_prefixes= []
      destination_application_security_group_ids  = [] 
      source_application_security_group_ids       = []
    }
  ]
}

variable "route_table_name" {
    description = "Route table name"
    default     = "example0001"
}

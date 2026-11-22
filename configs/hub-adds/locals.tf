locals {
  prefix         = local.hub_prefix
  subnet_type    = "private"
  resource_class = "ad"

  # e.g. CUSWDCP001: region code, TLA, environment code, ordinal.
  vm_name_prefix = upper("${local.loc_code}${var.tla}${local.env_code}")

  domain_controllers = {
    for i, vm in var.adds_vms : "${local.vm_name_prefix}${format("%03d", i + 1)}" => vm
  }

  # Inbound rules for Active Directory Domain Services, all from/to the virtual network.
  adds_rules = {
    ADDS_ADWS           = { priority = 2001, protocol = "Tcp", ports = ["9389"] }
    ADDS_Global_Catalog = { priority = 2002, protocol = "Tcp", ports = ["3268", "3269"] }
    ADDS_LDAP           = { priority = 2003, protocol = "*", ports = ["389"] }
    ADDS_LDAP_SSL       = { priority = 2004, protocol = "Tcp", ports = ["636"] }
    ADDS_IPSec          = { priority = 2005, protocol = "Udp", ports = ["500"] }
    ADDS_NAT            = { priority = 2006, protocol = "Udp", ports = ["4500"] }
    ADDS_RPC            = { priority = 2007, protocol = "Tcp", ports = ["135"] }
    ADDS_SMB            = { priority = 2008, protocol = "Tcp", ports = ["445"] }
    ADDS_DNS            = { priority = 2009, protocol = "*", ports = ["53"] }
    ADDS_Kerberos       = { priority = 2010, protocol = "*", ports = ["88"] }
    ADDS_NTP            = { priority = 2011, protocol = "Udp", ports = ["123"] }
    ADDS_NetBios_Udp    = { priority = 2012, protocol = "Udp", ports = ["137", "138"] }
    ADDS_NetBios_Tcp    = { priority = 2013, protocol = "Tcp", ports = ["139"] }
    ADDS_Kerberos_Pwd   = { priority = 2014, protocol = "*", ports = ["464"] }
    ADDS_DFSR           = { priority = 2015, protocol = "Tcp", ports = ["5722"] }
    ADDS_DHCP           = { priority = 2016, protocol = "Udp", ports = ["67"] }
    ADDS_MADCAP         = { priority = 2017, protocol = "Udp", ports = ["2535"] }
    ADDS_Ephemeral      = { priority = 2018, protocol = "*", ports = ["49152-65535"] }
  }
}

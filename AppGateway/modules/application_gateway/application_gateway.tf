resource "azurerm_application_gateway" "application_gateway" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name        = "Standard_v2"
    tier        = "Standard_v2"
    capacity    = 2
  }

  dynamic "gateway_ip_configuration" {
      for_each = var.gateway_ip_configuration_list

      content {
            name      = gateway_ip_configuration.value.name
            subnet_id = gateway_ip_configuration.value.subnet_id
      }
  }

  dynamic "frontend_ip_configuration" {
      for_each = var.frontend_ip_configuration_list

      content {
            name      = frontend_ip_configuration.value.name
            public_ip_address_id = frontend_ip_configuration.value.public_ip_address_id
      }
  }
  
  dynamic "frontend_port" {
      for_each = var.frontend_port_list

      content {
            name        = frontend_port.value.name
            port        = frontend_port.value.port
      }
  }

  dynamic "backend_address_pool" {
      for_each = var.backend_address_pool_list

      content {
            name            = backend_address_pool.value.name
            ip_addresses    = backend_address_pool.value.ip_address_list
            fqdns           = backend_address_pool.value.fqdn_list
      }
  }

  dynamic "backend_http_settings" {
      for_each = var.backend_http_setting_list

      content {
            name                    = backend_http_settings.value.name
            cookie_based_affinity   = backend_http_settings.value.cookie_based_affinity
            port                    = backend_http_settings.value.port
            protocol                = backend_http_settings.value.protocol
            request_timeout         = backend_http_settings.value.request_timeout
            probe_name              = backend_http_settings.value.probe_name

            pick_host_name_from_backend_address = true
      }
  }
  
  dynamic "http_listener" {
      for_each = var.http_listener_list

      content {
            name                            = http_listener.value.name
            frontend_ip_configuration_name  = http_listener.value.frontend_ip_configuration_name
            frontend_port_name              = http_listener.value.frontend_port_name
            protocol                        = http_listener.value.protocol
      }
  }

  dynamic "request_routing_rule" {
      for_each = var.request_routing_rule_list

      content {
            name                        = request_routing_rule.value.name
            rule_type                   = request_routing_rule.value.rule_type
            http_listener_name          = request_routing_rule.value.http_listener_name
            backend_address_pool_name   = request_routing_rule.value.backend_address_pool_name
            backend_http_settings_name  = request_routing_rule.value.backend_http_settings_name
      }
  }

  dynamic "probe" {
      for_each = var.health_probe_list

      content {
          name                        = probe.value.name
          interval                    = probe.value.interval
          protocol                    = probe.value.protocol
          port                        = probe.value.port

          path                        = probe.value.path
          timeout                     = probe.value.timeout
          unhealthy_threshold         = probe.value.unhealthy_threshold

          pick_host_name_from_backend_http_settings = true
          
      }
  }
  
  #ssl_policy {
  #  policy_type = "Predefined"
  #  policy_name = "AppGwSslPolicy20150501"
  #}

  #ssl_certificate {
  #  name        = "${var.environment}-CORE-VNET-WAF-SSL-CERT"
  #  data        = filebase64(var.ssl_certificate_file_name)
  #  password    = var.ssl_certificate_password
  #}
}
locals {
  frontend_ports = toset([for l in values(var.listeners) : l.port])
  redirects      = { for name, rule in var.routing_rules : name => rule.redirect_to_listener if rule.redirect_to_listener != null }

  frontend_names = {
    public  = "frontend-public"
    private = "frontend-private"
  }
}

resource "azurerm_web_application_firewall_policy" "this" {
  count = var.waf_enabled ? 1 : 0

  name                = "${var.name}-WAF-POLICY"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "Microsoft_DefaultRuleSet"
      version = "2.1"
    }

    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.1"
    }
  }
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  http2_enabled       = true
  firewall_policy_id  = one(azurerm_web_application_firewall_policy.this[*].id)
  tags                = var.tags

  sku {
    name = var.waf_enabled ? "WAF_v2" : "Standard_v2"
    tier = var.waf_enabled ? "WAF_v2" : "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 ? [] : [1]

    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_names.public
    public_ip_address_id = var.public_ip_address_id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_ip_address == null ? [] : [var.private_ip_address]

    content {
      name                          = local.frontend_names.private
      subnet_id                     = var.subnet_id
      private_ip_address            = frontend_ip_configuration.value
      private_ip_address_allocation = "Static"
    }
  }

  dynamic "frontend_port" {
    for_each = local.frontend_ports

    content {
      name = "port-${frontend_port.value}"
      port = frontend_port.value
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates

    content {
      name                = ssl_certificate.key
      key_vault_secret_id = ssl_certificate.value
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates

    content {
      name                = trusted_root_certificate.key
      key_vault_secret_id = trusted_root_certificate.value
    }
  }

  dynamic "http_listener" {
    for_each = var.listeners

    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = local.frontend_names[http_listener.value.frontend]
      frontend_port_name             = "port-${http_listener.value.port}"
      protocol                       = http_listener.value.protocol
      host_names                     = http_listener.value.host_names
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      require_sni                    = http_listener.value.protocol == "Https" && length(http_listener.value.host_names) > 0
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_pools

    content {
      name         = backend_address_pool.key
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_settings

    content {
      name                                = backend_http_settings.key
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      request_timeout                     = backend_http_settings.value.request_timeout
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      probe_name                          = backend_http_settings.value.probe_name
      trusted_root_certificate_names      = backend_http_settings.value.trusted_root_certificate_names

      connection_draining {
        enabled           = backend_http_settings.value.connection_draining_seconds > 0
        drain_timeout_sec = max(backend_http_settings.value.connection_draining_seconds, 1)
      }
    }
  }

  dynamic "probe" {
    for_each = var.probes

    content {
      name                                      = probe.key
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = probe.value.host
      pick_host_name_from_backend_http_settings = probe.value.host == null
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold

      match {
        status_code = probe.value.status_codes
      }
    }
  }

  dynamic "redirect_configuration" {
    for_each = local.redirects

    content {
      name                 = "redirect-${redirect_configuration.key}"
      redirect_type        = "Permanent"
      target_listener_name = redirect_configuration.value
      include_path         = true
      include_query_string = true
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.routing_rules

    content {
      name                        = request_routing_rule.key
      rule_type                   = "Basic"
      priority                    = request_routing_rule.value.priority
      http_listener_name          = request_routing_rule.value.listener_name
      backend_address_pool_name   = request_routing_rule.value.backend_pool_name
      backend_http_settings_name  = request_routing_rule.value.backend_settings_name
      redirect_configuration_name = request_routing_rule.value.redirect_to_listener == null ? null : "redirect-${request_routing_rule.key}"
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "LOGANALYTICS-DIAGNOSTICS"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Resource-specific tables (AGWAccessLogs, AGWFirewallLogs) are cheaper to query than AzureDiagnostics.
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

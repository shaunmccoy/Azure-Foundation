locals {
  premium = var.sku_tier == "Premium"
  zones   = local.premium ? var.zones : []

  # Every region the gateway runs in, primary first.
  regions = merge(
    { (var.location) = { subnet_id = var.subnet_id, zones = local.zones } },
    { for location, cfg in var.additional_locations : location => { subnet_id = cfg.subnet_id, zones = cfg.zones } },
  )
}

# Identity the service uses for Key Vault and Application Insights. Created before the
# service so its role assignments exist when custom domains and loggers are configured.
resource "azurerm_user_assigned_identity" "this" {
  name                = "${var.name}-IDENTITY"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "key_vault" {
  for_each = var.key_vault_ids

  scope                = each.value
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"
}

# VNet-injected (stv2) instances need a Standard public IP with a DNS label in each region,
# even in Internal mode, where it carries management-plane traffic only.
resource "azurerm_public_ip" "this" {
  for_each = local.regions

  name                = "${var.name}-PIP-${upper(each.key)}"
  resource_group_name = var.resource_group_name
  location            = each.key
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = length(each.value.zones) > 0 ? ["1", "2", "3"] : []
  domain_name_label   = lower("${var.name}-${each.key}")
  tags                = var.tags
}

resource "azurerm_api_management" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "${var.sku_tier}_${var.capacity}"
  zones               = local.zones
  min_api_version     = var.min_api_version
  gateway_disabled    = length(var.additional_locations) > 0 ? var.primary_gateway_disabled : null
  tags                = var.tags

  virtual_network_type = var.virtual_network_type
  public_ip_address_id = azurerm_public_ip.this[var.location].id

  virtual_network_configuration {
    subnet_id = var.subnet_id
  }

  dynamic "additional_location" {
    for_each = var.additional_locations

    content {
      location             = additional_location.key
      capacity             = additional_location.value.capacity
      zones                = additional_location.value.zones
      gateway_disabled     = additional_location.value.gateway_disabled
      public_ip_address_id = azurerm_public_ip.this[additional_location.key].id

      virtual_network_configuration {
        subnet_id = additional_location.value.subnet_id
      }
    }
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  protocols {
    http2_enabled = true
  }

  # TLS 1.2+ with AEAD/ECDHE suites only, towards clients and backends.
  security {
    frontend_ssl30_enabled = false
    frontend_tls10_enabled = false
    frontend_tls11_enabled = false
    backend_ssl30_enabled  = false
    backend_tls10_enabled  = false
    backend_tls11_enabled  = false

    triple_des_ciphers_enabled                          = false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = false
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = false
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = false
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = false
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = false
  }

  # Developer portal: sign-in required, self-service sign-up off.
  sign_in {
    enabled = true
  }

  sign_up {
    enabled = false

    terms_of_service {
      enabled          = false
      consent_required = false
    }
  }

  # No shared-key access to the management API; use Entra ID and Azure RBAC.
  tenant_access {
    enabled = false
  }

  # Creating or adding a region to a VNet-injected service routinely takes over an hour.
  timeouts {
    create = "4h"
    update = "4h"
    delete = "3h"
  }

  depends_on = [azurerm_subnet_network_security_group_association.this]
}

resource "azurerm_api_management_custom_domain" "this" {
  count = length(var.gateway_custom_domains) > 0 || var.developer_portal_custom_domain != null || var.management_custom_domain != null ? 1 : 0

  api_management_id = azurerm_api_management.this.id

  dynamic "gateway" {
    for_each = var.gateway_custom_domains

    content {
      host_name                       = gateway.value.host_name
      key_vault_certificate_id        = gateway.value.key_vault_certificate_id
      default_ssl_binding             = gateway.value.default_ssl_binding
      negotiate_client_certificate    = gateway.value.negotiate_client_certificate
      ssl_keyvault_identity_client_id = azurerm_user_assigned_identity.this.client_id
    }
  }

  dynamic "developer_portal" {
    for_each = var.developer_portal_custom_domain == null ? [] : [var.developer_portal_custom_domain]

    content {
      host_name                       = developer_portal.value.host_name
      key_vault_certificate_id        = developer_portal.value.key_vault_certificate_id
      ssl_keyvault_identity_client_id = azurerm_user_assigned_identity.this.client_id
    }
  }

  dynamic "management" {
    for_each = var.management_custom_domain == null ? [] : [var.management_custom_domain]

    content {
      host_name                       = management.value.host_name
      key_vault_certificate_id        = management.value.key_vault_certificate_id
      ssl_keyvault_identity_client_id = azurerm_user_assigned_identity.this.client_id
    }
  }

  depends_on = [azurerm_role_assignment.key_vault]
}

resource "azurerm_api_management_named_value" "this" {
  for_each = var.named_values

  name                = each.key
  display_name        = each.key
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  secret              = true

  value_from_key_vault {
    secret_id          = each.value
    identity_client_id = azurerm_user_assigned_identity.this.client_id
  }

  depends_on = [azurerm_role_assignment.key_vault]
}

resource "azurerm_management_lock" "this" {
  count = var.delete_lock_enabled ? 1 : 0

  name       = "${var.name}-DO-NOT-DELETE"
  scope      = azurerm_api_management.this.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform. Remove through Terraform, not the portal."
}

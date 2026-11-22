
variable "app_gateway_name" {}
variable "resource_group_name" {}
variable "location" {}

variable "gateway_ip_configuration_list" {
    description = "Gateway IP configuration list with fields: name, subnet_id"
    type = list
}
variable "frontend_ip_configuration_list" {
    description = "Frontend IP configuration list with fields: name, public_ip_address_id"
    type = list
}
variable "frontend_port_list" {
    description = "Frontend port list with fields: name, port"
    type = list
}
variable "backend_address_pool_list" {
    description = "Backend pool list with fields: name, ip_address_list"
    type = list
}
variable "backend_http_setting_list" {
    description = "Backend HTTP Setting list with fields: name, cookie_based_affinity, port, protocol, request_timeout"
    type = list
}
variable "http_listener_list" {
    description = "Http listener list with fields: name, frontend_ip_configuration_name, frontend_port_name, host_name, protocol"
    type = list
}
variable "request_routing_rule_list" {
    description = "Request routing rule list with fields: name, rule_type, http_listener_name, backend_address_pool_name, backend_http_settings_name"
    type = list
}
variable "health_probe_list" {
    description = "Request routing rule list with fields: name, host, interval, protocol, port, path, request_timeout, unhealthy_threshold"
    type = list
}


output "application_gateway_id" {
  description = "Application Gateway resource ID."
  value       = module.application_gateway.id
}

output "public_ip_id" {
  description = "Public IP resource ID. Use it as an endpoint in configs/global-ingress."
  value       = module.public_ip.id
}

output "public_ip_address" {
  description = "Public IP address of the gateway."
  value       = module.public_ip.ip_address
}

output "public_fqdn" {
  description = "Regional DNS name of the gateway."
  value       = module.public_ip.fqdn
}

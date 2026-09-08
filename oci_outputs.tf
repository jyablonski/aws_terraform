output "oci_public_ip" {
  description = "Reserved public IPv4 address for the Cloudflare baseline A record."
  value       = oci_core_public_ip.a1_flex.ip_address
}

output "oci_ssh_username" {
  description = "SSH username for the OCI A1.Flex instance and the OCI_USER CI secret."
  value       = "ubuntu"
}

output "oci_ssh_connection" {
  description = "SSH command for connecting to the OCI instance as Ubuntu's default user."
  value       = "ssh ubuntu@${oci_core_public_ip.a1_flex.ip_address}"
}

output "oci_postgres_endpoint" {
  description = "Public IPv4 endpoint for the NBA Postgres service exposed on TCP 5432."
  value       = "${oci_core_public_ip.a1_flex.ip_address}:5432"
}

output "oci_mcp_endpoint" {
  description = "Public HTTP endpoint for the authenticated NBA MCP service."
  value       = "http://${oci_core_public_ip.a1_flex.ip_address}:8001/mcp"
}

output "oci_availability_domain" {
  description = "Tenancy-specific OCI availability domain; the configured index falls back to the first AD in single-AD regions."
  value       = local.oci_availability_domain
}

output "oci_budget_id" {
  description = "OCID of the tenancy-root $1 monthly OCI sandbox budget."
  value       = oci_budget_budget.sandbox.id
}

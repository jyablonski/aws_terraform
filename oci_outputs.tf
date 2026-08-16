output "oci_public_ip" {
  description = "Ephemeral public IPv4 address assigned to the OCI A1.Flex instance."
  value       = oci_core_instance.a1_flex.public_ip
}

output "oci_ssh_connection" {
  description = "SSH command for connecting to the OCI instance as Ubuntu's default user."
  value       = "ssh ubuntu@${oci_core_instance.a1_flex.public_ip}"
}

output "oci_availability_domain" {
  description = "Tenancy-specific OCI availability domain selected by the configured local AD index."
  value       = local.oci_availability_domain
}

output "oci_budget_id" {
  description = "OCID of the tenancy-root $1 monthly OCI sandbox budget."
  value       = oci_budget_budget.sandbox.id
}

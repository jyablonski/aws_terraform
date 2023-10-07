output "storage_integration_name" {
  value = snowflake_storage_integration.this.name
}

output "storage_integration_user_arn" {
  value = snowflake_storage_integration.this.storage_aws_iam_user_arn
}

output "storage_integration_external_id" {
  value = snowflake_storage_integration.this.storage_aws_external_id
}

output "iam_role_arn" {
  value = aws_iam_role.this.arn
}
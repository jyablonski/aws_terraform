output "stage_name" {
  value = snowflake_stage.this.name
}

output "stage_qualified_name" {
  value = snowflake_stage.this.fully_qualified_name
}
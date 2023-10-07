output "schema_name" {
  value = snowflake_schema.this.name
}

output "schema_db_name" {
  value = snowflake_schema.this.database
}
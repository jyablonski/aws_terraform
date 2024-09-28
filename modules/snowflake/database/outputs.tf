output "db_name" {
  value = snowflake_database.this.name
}

output "db_retention_time" {
  value = snowflake_database.this.data_retention_time_in_days
}

output "db_is_transient" {
  value = snowflake_database.this.is_transient
}
output "db_name" {
  value = snowflake_database.module_db.name
}

output "db_retention_time" {
  value = snowflake_database.module_db.data_retention_time_in_days
}

output "db_is_transient" {
  value = snowflake_database.module_db.is_transient
}
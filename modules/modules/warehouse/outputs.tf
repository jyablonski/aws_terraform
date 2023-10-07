output "role_warehouse_name" {
  value = snowflake_warehouse.this.name
}

output "role_warehouse_size" {
  value = snowflake_warehouse.this.warehouse_size
}
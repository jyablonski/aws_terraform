output "role_name" {
  value = snowflake_account_role.module_role.name
}

output "role_warehouse_name" {
  value = snowflake_warehouse.module_role_warehouse.name
}

output "role_warehouse_size" {
  value = snowflake_warehouse.module_role_warehouse.warehouse_size
}


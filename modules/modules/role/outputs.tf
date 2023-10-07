output "role_name" {
  value = snowflake_role.module_role.name
}

output "role_warehouse_name" {
  value = snowflake_warehouse.module_role_warehouse.name
}

output "role_warehouse_size" {
  value = snowflake_warehouse.module_role_warehouse.warehouse_size
}

output "role_warehouse_privilege" {
  value = snowflake_warehouse_grant.module_role_warehouse_grant.privilege
}
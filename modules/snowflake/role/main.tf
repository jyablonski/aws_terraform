terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.72"
    }

  }
}

resource "snowflake_role" "module_role" {
  name    = var.role_name
  comment = var.role_comment
}

resource "snowflake_warehouse" "module_role_warehouse" {
  name                                = "${var.role_name}_WAREHOUSE"
  comment                             = "Warehouse for Role ${var.role_name}"
  warehouse_size                      = var.role_warehouse_size
  enable_query_acceleration           = false
  query_acceleration_max_scale_factor = 0

  auto_resume         = true
  auto_suspend        = 180
  initially_suspended = true
}

resource "snowflake_warehouse_grant" "module_role_warehouse_grant_usage" {
  warehouse_name         = snowflake_warehouse.module_role_warehouse.name
  enable_multiple_grants = true
  privilege              = "USAGE"

  roles = [
    snowflake_role.module_role.name,
  ]

  with_grant_option = false
}

resource "snowflake_warehouse_grant" "module_role_warehouse_grant" {
  warehouse_name         = snowflake_warehouse.module_role_warehouse.name
  enable_multiple_grants = true
  privilege              = var.role_warehouse_privilege

  roles = [
    snowflake_role.module_role.name,
  ]

  with_grant_option = false
}

resource "snowflake_database" "module_role_db" {
  name                        = "${var.role_name}_DEV"
  comment                     = "${var.role_name}_DEV Database"
  data_retention_time_in_days = 1
  is_transient                = false
}

resource "snowflake_database_grant" "module_role_grant_db_ownership" {
  database_name          = snowflake_database.module_role_db.name
  enable_multiple_grants = true

  privilege = "OWNERSHIP"
  roles     = [var.role_name]

  with_grant_option = false
}

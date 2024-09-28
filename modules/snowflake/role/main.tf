terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.72"
    }

  }
}

resource "snowflake_account_role" "module_role" {
  name    = var.role_name
  comment = var.role_comment
}

resource "snowflake_warehouse" "module_role_warehouse" {
  name                                = "${var.role_name}_WAREHOUSE"
  comment                             = "Warehouse for Role ${var.role_name}"
  warehouse_size                      = var.role_warehouse_size
  enable_query_acceleration           = false
  query_acceleration_max_scale_factor = null

  auto_resume         = true
  auto_suspend        = 180
  initially_suspended = true
}

resource "snowflake_grant_ownership" "module_role_warehouse_grant_usage" {
  account_role_name = snowflake_account_role.module_role.name

  on {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.module_role_warehouse.name
  }

}

resource "snowflake_database" "module_role_db" {
  name                        = "${var.role_name}_DEV"
  comment                     = "${var.role_name}_DEV Database"
  data_retention_time_in_days = 1
  is_transient                = false
}

resource "snowflake_grant_privileges_to_account_role" "module_role_grant_db_ownership" {
  account_role_name = snowflake_account_role.module_role.name

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.module_role_db.name
  }
  all_privileges    = true
  with_grant_option = false
}

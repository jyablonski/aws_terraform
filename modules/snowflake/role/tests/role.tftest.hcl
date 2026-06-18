mock_provider "snowflake" {}

variables {
  role_name    = "UNIT_ROLE"
  role_comment = "Unit role"
}

run "valid_inputs_create_role_warehouse_and_database" {
  command = plan

  assert {
    condition     = snowflake_account_role.module_role.name == "UNIT_ROLE"
    error_message = "Account role name should come from role_name."
  }

  assert {
    condition     = snowflake_warehouse.module_role_warehouse.name == "UNIT_ROLE_WAREHOUSE"
    error_message = "Role warehouse name should be derived from role_name."
  }

  assert {
    condition     = snowflake_database.module_role_db.name == "UNIT_ROLE_DEV"
    error_message = "Role database name should be derived from role_name."
  }
}

run "defaults_configure_role_warehouse" {
  command = plan

  assert {
    condition     = snowflake_warehouse.module_role_warehouse.warehouse_size == "X-SMALL"
    error_message = "Default role warehouse size should be X-SMALL."
  }

  assert {
    condition     = snowflake_warehouse.module_role_warehouse.auto_suspend == 180
    error_message = "Role warehouse should auto suspend after 180 seconds."
  }

  assert {
    condition     = output.role_warehouse_size == "X-SMALL"
    error_message = "role_warehouse_size output should expose the warehouse size."
  }
}

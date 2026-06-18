# warehouse_scaling_policy, min_cluster_count, and max_cluster_count are defined
# as variables but the related resource arguments are currently commented out.

mock_provider "snowflake" {}

variables {
  warehouse_name = "UNIT_WAREHOUSE"
  role_names     = ["UNIT_READER", "UNIT_WRITER"]
}

run "valid_inputs_configure_warehouse_and_outputs" {
  command = plan

  assert {
    condition     = snowflake_warehouse.this.name == "UNIT_WAREHOUSE"
    error_message = "Warehouse name should come from warehouse_name."
  }

  assert {
    condition     = output.role_warehouse_name == "UNIT_WAREHOUSE"
    error_message = "Warehouse name output should expose the warehouse name."
  }

  assert {
    condition     = output.role_warehouse_size == "X-SMALL"
    error_message = "Warehouse size output should expose the default size."
  }
}

run "defaults_configure_operational_settings" {
  command = plan

  assert {
    condition     = snowflake_warehouse.this.warehouse_size == "X-SMALL"
    error_message = "Default warehouse size should be X-SMALL."
  }

  assert {
    condition     = snowflake_warehouse.this.statement_timeout_in_seconds == 1200
    error_message = "Default statement timeout should be 1200 seconds."
  }

  assert {
    condition     = snowflake_warehouse.this.auto_suspend == 180
    error_message = "Warehouse should auto suspend after 180 seconds."
  }
}

run "role_names_drive_grant_count" {
  command = plan

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.this) == 2
    error_message = "Two role names should create two warehouse usage grants."
  }
}

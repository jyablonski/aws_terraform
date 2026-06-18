# db_ownership_access and db_access are currently not referenced by the module;
# grant creation is driven directly by db_ownership_roles and db_access_roles.

mock_provider "aws" {}
mock_provider "snowflake" {}

variables {
  db_name            = "UNIT_DB"
  db_ownership_roles = ["UNIT_ADMIN"]
  db_access_roles    = ["UNIT_READER", "UNIT_WRITER"]
}

run "valid_inputs_configure_database_and_outputs" {
  command = plan

  assert {
    condition     = snowflake_database.this.name == "UNIT_DB"
    error_message = "Database name should come from db_name."
  }

  assert {
    condition     = output.db_name == "UNIT_DB"
    error_message = "db_name output should expose the database name."
  }

  assert {
    condition     = output.db_retention_time == 1
    error_message = "Default retention output should be 1 day."
  }
}

run "defaults_configure_retention_and_transience" {
  command = plan

  variables {
    db_ownership_roles = []
    db_access_roles    = []
  }

  assert {
    condition     = snowflake_database.this.comment == ""
    error_message = "Default database comment should be empty."
  }

  assert {
    condition     = snowflake_database.this.data_retention_time_in_days == 1
    error_message = "Default data retention should be 1 day."
  }

  assert {
    condition     = snowflake_database.this.is_transient == false
    error_message = "Database should not be transient by default."
  }
}

run "role_lists_drive_grant_counts" {
  command = plan

  assert {
    condition     = length(snowflake_grant_ownership.database_ownership) == 1
    error_message = "One ownership role should create one ownership grant."
  }

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.this) == 2
    error_message = "Two access roles should create two usage grants."
  }
}

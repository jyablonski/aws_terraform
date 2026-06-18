mock_provider "snowflake" {}

variables {
  db_name            = "UNIT_DB"
  schema_name        = "UNIT_SCHEMA"
  schema_admin_roles = ["UNIT_ADMIN"]
  schema_write_roles = ["UNIT_WRITER"]
  schema_read_roles  = ["UNIT_READER", "UNIT_ANALYST"]
}

run "valid_inputs_configure_schema_and_outputs" {
  command = plan

  assert {
    condition     = snowflake_schema.this.database == "UNIT_DB"
    error_message = "Schema database should come from db_name."
  }

  assert {
    condition     = snowflake_schema.this.name == "UNIT_SCHEMA"
    error_message = "Schema name should come from schema_name."
  }

  assert {
    condition     = output.schema_name == "UNIT_SCHEMA"
    error_message = "schema_name output should expose the schema name."
  }
}

run "defaults_configure_schema_options" {
  command = plan

  variables {
    schema_admin_roles = []
    schema_write_roles = []
    schema_read_roles  = []
  }

  assert {
    condition     = snowflake_schema.this.comment == ""
    error_message = "Default schema comment should be empty."
  }

  assert {
    condition     = snowflake_schema.this.is_transient == "false"
    error_message = "Schema should not be transient by default."
  }

  assert {
    condition     = snowflake_schema.this.with_managed_access == "false"
    error_message = "Schema should not use managed access by default."
  }
}

run "role_lists_drive_grant_counts" {
  command = plan

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.ownership_privileges) == 1
    error_message = "One admin role should create one schema ownership privilege grant."
  }

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.write_privileges_on_schema) == 1
    error_message = "One write role should create one schema write grant."
  }

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.select_privileges_on_schema) == 2
    error_message = "Two read roles should create two schema usage grants."
  }
}

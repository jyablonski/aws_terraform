mock_provider "snowflake" {}

variables {
  pipe_db                = "UNIT_DB"
  pipe_schema            = "PUBLIC"
  pipe_name              = "UNIT_PIPE"
  pipe_comment           = "Unit pipe"
  pipe_destination_table = "UNIT_TABLE"
  pipe_stage             = "UNIT_STAGE"
  file_format            = "TYPE = CSV"
}

run "valid_inputs_configure_pipe_and_output" {
  command = plan

  assert {
    condition     = snowflake_pipe.this.name == "UNIT_PIPE"
    error_message = "Pipe name should come from pipe_name."
  }

  assert {
    condition     = snowflake_pipe.this.auto_ingest == true
    error_message = "auto_ingest should default to true."
  }

  assert {
    condition     = output.pipe_name == "UNIT_PIPE"
    error_message = "pipe_name output should expose the pipe name."
  }
}

run "copy_statement_is_derived_from_inputs" {
  command = plan

  variables {
    copy_options = "ON_ERROR = CONTINUE"
  }

  assert {
    condition     = strcontains(snowflake_pipe.this.copy_statement, "COPY INTO UNIT_DB.PUBLIC.UNIT_TABLE")
    error_message = "Copy statement should target the destination table."
  }

  assert {
    condition     = strcontains(snowflake_pipe.this.copy_statement, "FROM @UNIT_STAGE")
    error_message = "Copy statement should read from the configured stage."
  }

  assert {
    condition     = strcontains(snowflake_pipe.this.copy_statement, "ON_ERROR = CONTINUE")
    error_message = "Copy statement should include copy_options."
  }
}

run "usage_roles_default_to_accountadmin" {
  command = plan

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.this) == 1
    error_message = "Default usage_roles should create one grant."
  }

  assert {
    condition     = snowflake_grant_privileges_to_account_role.this["ACCOUNTADMIN"].account_role_name == "ACCOUNTADMIN"
    error_message = "Default usage role should be ACCOUNTADMIN."
  }
}

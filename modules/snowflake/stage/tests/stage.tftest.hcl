mock_provider "snowflake" {}

variables {
  stage_name               = "UNIT_STAGE"
  stage_url                = "s3://unit-bucket/path/"
  stage_db                 = "UNIT_DB"
  stage_schema             = "PUBLIC"
  storage_integration_name = "UNIT_STORAGE_INTEGRATION"
  stage_usage_roles        = ["UNIT_READER", "UNIT_WRITER"]
}

run "valid_inputs_configure_stage_and_output" {
  command = plan

  assert {
    condition     = snowflake_stage.this.name == "UNIT_STAGE"
    error_message = "Stage name should come from stage_name."
  }

  assert {
    condition     = snowflake_stage.this.url == "s3://unit-bucket/path/"
    error_message = "Stage URL should come from stage_url."
  }

  assert {
    condition     = output.stage_name == "UNIT_STAGE"
    error_message = "stage_name output should expose the stage name."
  }
}

run "usage_roles_drive_grant_count" {
  command = plan

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.select_privileges_on_schema) == 2
    error_message = "Two stage usage roles should create two grants."
  }
}

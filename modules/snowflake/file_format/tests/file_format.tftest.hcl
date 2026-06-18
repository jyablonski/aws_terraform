mock_provider "aws" {}
mock_provider "snowflake" {}

variables {
  name                    = "UNIT_FORMAT"
  database                = "UNIT_DB"
  schema                  = "PUBLIC"
  format_type             = "CSV"
  file_format_usage_roles = ["UNIT_READER", "UNIT_WRITER"]
}

run "valid_inputs_configure_file_format_and_output" {
  command = plan

  assert {
    condition     = snowflake_file_format.this.name == "UNIT_FORMAT"
    error_message = "File format name should come from name."
  }

  assert {
    condition     = snowflake_file_format.this.database == "UNIT_DB"
    error_message = "File format database should come from database."
  }

  assert {
    condition     = output.file_format == "UNIT_FORMAT"
    error_message = "file_format output should expose the file format name."
  }
}

run "optional_format_parameters_are_configured" {
  command = plan

  variables {
    compression = "GZIP"
    skip_header = 1
    null_if     = ["NULL", ""]
  }

  assert {
    condition     = snowflake_file_format.this.compression == "GZIP"
    error_message = "compression should use the supplied value."
  }

  assert {
    condition     = snowflake_file_format.this.skip_header == 1
    error_message = "skip_header should use the supplied value."
  }

  assert {
    condition     = length(snowflake_file_format.this.null_if) == 2 && contains(snowflake_file_format.this.null_if, "NULL") && contains(snowflake_file_format.this.null_if, "")
    error_message = "null_if should use the supplied values."
  }
}

run "usage_roles_drive_grant_count" {
  command = plan

  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.file_format_usage) == 2
    error_message = "Two usage roles should create two grants."
  }
}

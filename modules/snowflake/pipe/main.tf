terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "1.0.5"
    }

  }
}

resource "snowflake_pipe" "this" {
  database = var.pipe_db
  schema   = var.pipe_schema
  name     = var.pipe_name
  comment  = var.pipe_comment

  copy_statement = <<-EOF
    COPY INTO ${var.pipe_db}.${var.pipe_schema}.${var.pipe_destination_table}
    FROM @${var.pipe_stage}
    FILE_FORMAT = ${var.file_format}
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    INCLUDE_METADATA = (LOADED_AT = METADATA$START_SCAN_TIME)
    ${var.copy_options}
  EOF

  auto_ingest = var.is_auto_ingest
  # integration       = var.storage_integration

  # Only set error_integration if var.error_integration is not null
  # error_integration = var.error_integration != "" ? var.error_integration : null

}

resource "snowflake_grant_privileges_to_account_role" "this" {
  for_each = toset(var.usage_roles)

  account_role_name = each.value
  privileges        = ["MONITOR"]

  on_schema_object {
    object_type = "PIPE"
    object_name = snowflake_pipe.this.fully_qualified_name
  }

  with_grant_option = false
}

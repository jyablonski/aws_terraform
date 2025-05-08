terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "1.0.5"
    }

  }
}


resource "snowflake_file_format" "this" {
  name        = var.name
  database    = var.database
  schema      = var.schema
  format_type = var.format_type

  # Optional parameters
  compression             = var.compression
  record_delimiter        = var.record_delimiter
  field_delimiter         = var.field_delimiter
  file_extension          = var.file_extension
  skip_header             = var.skip_header
  binary_as_text          = var.binary_as_text
  trim_space              = var.trim_space
  null_if                 = var.null_if
  empty_field_as_null     = var.empty_field_as_null
  enable_octal            = var.enable_octal
  escape_unenclosed_field = var.escape_unenclosed_field
  encoding                = var.encoding
  date_format             = var.date_format
  time_format             = var.time_format
  timestamp_format        = var.timestamp_format
  binary_format           = var.binary_format
}

resource "snowflake_grant_privileges_to_account_role" "file_format_usage" {
  for_each = toset(var.file_format_usage_roles)

  privileges        = ["USAGE"]
  account_role_name = each.value

  on_schema_object {
    object_type = "FILE FORMAT"
    object_name = snowflake_file_format.this.fully_qualified_name
  }
}

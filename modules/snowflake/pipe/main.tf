terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.96.0"
    }

  }
}

resource "snowflake_pipe" "this" {
  database = var.pipe_db
  schema   = var.pipe_schema
  name     = var.pipe_name

  comment = var.pipe_comment

  copy_statement    = var.pipe_copy_statement
  auto_ingest       = var.is_auto_ingest
  integration       = var.storage_integration
  error_integration = var.error_integration

}

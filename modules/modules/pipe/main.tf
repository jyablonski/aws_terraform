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

resource "snowflake_pipe_grant" "this" {
  database_name = var.pipe_db
  schema_name   = var.pipe_schema
  pipe_name     = snowflake_pipe.this.name

  privilege = "OPERATE"
  roles     = var.roles

  on_future         = true
  with_grant_option = false
}
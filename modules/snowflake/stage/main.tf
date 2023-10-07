terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.72"
    }

  }
}

resource "snowflake_stage" "this" {
  name                = var.stage_name
  url                 = var.stage_url
  database            = var.stage_db
  schema              = var.stage_schema
  storage_integration = var.storage_integration_name
}

resource "snowflake_stage_grant" "this" {
  database_name = snowflake_stage.this.database
  schema_name   = snowflake_stage.this.schema
  roles         = var.stage_role
  privilege     = "USAGE"
  stage_name    = snowflake_stage.this.name

  with_grant_option = false
}
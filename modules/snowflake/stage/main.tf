terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.96.0"
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


resource "snowflake_grant_privileges_to_account_role" "select_privileges_on_schema" {
  for_each = toset(var.stage_usage_roles)

  account_role_name = each.value
  privileges        = ["USAGE"]

  on_schema_object {
    object_type = "STAGE"
    object_name = snowflake_stage.this.fully_qualified_name
  }

  with_grant_option = false
}

# resource "snowflake_stage_grant" "this" {
#   database_name = snowflake_stage.this.database
#   schema_name   = snowflake_stage.this.schema
#   roles         = var.stage_role
#   privilege     = "USAGE"
#   stage_name    = snowflake_stage.this.name

#   with_grant_option = false
# }

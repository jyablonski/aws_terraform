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

resource "snowflake_database" "this" {
  name                        = var.db_name
  comment                     = var.db_comment
  data_retention_time_in_days = var.db_retention_time
  is_transient                = var.db_is_transient
}

resource "snowflake_grant_ownership" "database_ownership" {
  for_each = toset(var.db_ownership_roles)

  account_role_name = each.value

  on {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }

}

resource "snowflake_grant_privileges_to_account_role" "this" {
  for_each = toset(var.db_access_roles)

  account_role_name = each.value
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }

  with_grant_option = false
}


# resource "snowflake_database_grant" "module_grant_db_write_usage" {
#   # tflint-ignore: terraform_required_providers
#   count = var.db_access ? 1 : 0

#   database_name          = snowflake_database.module_db.name
#   enable_multiple_grants = true

#   privilege = "USAGE"
#   roles     = var.db_access_roles

#   with_grant_option = false
# }

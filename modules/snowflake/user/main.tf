terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.96.0"
    }

  }
}

resource "snowflake_user" "this" {
  name         = var.user_name
  login_name   = var.user_name
  comment      = var.user_comment
  password     = "Testpassword123!"
  disabled     = false
  display_name = var.user_email
  email        = var.user_email
  first_name   = var.user_first_name
  last_name    = var.user_last_name

  default_role = var.roles[0] # the first role passed in is their default role

  rsa_public_key = var.user_rsa_key

  must_change_password = true

  lifecycle {
    ignore_changes = [
      must_change_password
    ]
  }
}

resource "snowflake_grant_account_role" "this" {
  for_each  = toset(var.roles)
  role_name = each.value
  user_name = snowflake_user.this.name
}

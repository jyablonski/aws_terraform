resource "snowflake_user" "this" {
  name         = var.user_name
  login_name   = var.user_name
  comment      = var.user_comment
  password     = var.user_password
  disabled     = false
  display_name = var.user_email
  email        = var.user_email
  first_name   = var.user_first_name
  last_name    = var.user_last_name

  # default_warehouse       = var.user_default_warehouse
  # default_secondary_roles = ["ALL"] # this might not be correct
  default_role            = var.roles[0] # the first role passed in is their default role

  rsa_public_key = var.user_rsa_key
  #   rsa_public_key_2 = "..." - this is only used for rotating key pairs?  don't think it's necessary

  must_change_password = true
}

resource "snowsql_exec" "this" {

  for_each = toset(var.roles)

  name = "${each.key}_select_grant"

  create {
    statements = <<-EOT
    GRANT ROLE ${each.key} TO USER ${snowflake_user.this.name};
    EOT
  }

  delete {
    statements = <<-EOT
    REVOKE ROLE ${each.key} FROM USER ${snowflake_user.this.name};
    EOT
  }
}

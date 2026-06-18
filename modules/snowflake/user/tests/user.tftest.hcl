# roles must contain at least one entry because snowflake_user.this.default_role
# reads var.roles[0].

mock_provider "snowflake" {}

variables {
  user_name       = "UNIT_USER"
  user_comment    = "Unit user"
  user_email      = "unit@example.com"
  user_first_name = "Unit"
  user_last_name  = "User"
  roles           = ["UNIT_ROLE", "UNIT_EXTRA_ROLE"]
}

run "valid_inputs_configure_user_and_outputs" {
  command = plan

  assert {
    condition     = snowflake_user.this.name == "UNIT_USER"
    error_message = "User name should come from user_name."
  }

  assert {
    condition     = snowflake_user.this.default_role == "UNIT_ROLE"
    error_message = "Default role should be the first item in roles."
  }

  assert {
    condition     = nonsensitive(output.user_email) == "unit@example.com"
    error_message = "user_email output should expose the user email."
  }
}

run "roles_drive_grant_count" {
  command = plan

  assert {
    condition     = length(snowflake_grant_account_role.this) == 2
    error_message = "Two roles should create two account role grants."
  }
}

mock_provider "postgresql" {}

variables {
  role_name     = "unit_role"
  role_password = "unit-password"
}

run "valid_inputs_configure_role_and_output" {
  command = plan

  assert {
    condition     = postgresql_role.this.name == "unit_role"
    error_message = "Role name should come from role_name."
  }

  assert {
    condition     = postgresql_role.this.login == true
    error_message = "Role should be configured for login."
  }

  assert {
    condition     = output.role_name == "unit_role"
    error_message = "role_name output should expose the role name."
  }
}

run "defaults_keep_role_non_superuser" {
  command = plan

  assert {
    condition     = postgresql_role.this.superuser == false
    error_message = "Role should not be superuser."
  }
}

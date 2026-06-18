mock_provider "postgresql" {}

variables {
  schema_name        = "unit_schema"
  database_name      = "unit_db"
  schema_owner       = "unit_owner"
  read_access_roles  = ["unit_reader", "unit_analyst"]
  write_access_roles = ["unit_writer"]
  admin_access_roles = ["unit_admin"]
}

run "valid_inputs_configure_schema_and_output" {
  command = plan

  assert {
    condition     = postgresql_schema.this.name == "unit_schema"
    error_message = "Schema name should come from schema_name."
  }

  assert {
    condition     = postgresql_schema.this.database == "unit_db"
    error_message = "Schema database should come from database_name."
  }

  assert {
    condition     = output.schema_name == "unit_schema"
    error_message = "schema_name output should expose the schema name."
  }
}

run "read_write_and_admin_roles_drive_grant_counts" {
  command = plan

  assert {
    condition     = length(postgresql_grant.read_only_access_grant) == 2
    error_message = "Two read roles should create two current table read grants."
  }

  assert {
    condition     = length(postgresql_grant.write_access_grant) == 1
    error_message = "One write role should create one current table write grant."
  }

  assert {
    condition     = length(postgresql_grant.admin_access_grant) == 1
    error_message = "One admin role should create one current table admin grant."
  }
}

run "empty_role_lists_create_only_schema" {
  command = plan

  variables {
    read_access_roles  = []
    write_access_roles = []
    admin_access_roles = []
  }

  assert {
    condition     = length(postgresql_grant.read_only_access_grant) == 0
    error_message = "Empty read_access_roles should create no read grants."
  }

  assert {
    condition     = length(postgresql_grant.write_access_grant) == 0
    error_message = "Empty write_access_roles should create no write grants."
  }

  assert {
    condition     = length(postgresql_grant.admin_access_grant) == 0
    error_message = "Empty admin_access_roles should create no admin grants."
  }
}

run "grant_privileges_match_access_level" {
  command = plan

  assert {
    condition     = length(postgresql_grant.read_only_access_grant["unit_reader"].privileges) == 1 && contains(postgresql_grant.read_only_access_grant["unit_reader"].privileges, "SELECT")
    error_message = "Read role table grants should only include SELECT."
  }

  assert {
    condition = length(postgresql_grant.write_access_grant["unit_writer"].privileges) == 5 && alltrue([
      for privilege in ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE"] :
      contains(postgresql_grant.write_access_grant["unit_writer"].privileges, privilege)
    ])
    error_message = "Write role table grants should include write privileges."
  }

  assert {
    condition = length(postgresql_grant.admin_access_grant["unit_admin"].privileges) == 7 && alltrue([
      for privilege in ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "TRIGGER", "REFERENCES"] :
      contains(postgresql_grant.admin_access_grant["unit_admin"].privileges, privilege)
    ])
    error_message = "Admin role table grants should include full configured privileges."
  }
}

mock_provider "postgresql" {}

variables {
  database_name  = "unit_db"
  database_owner = "unit_owner"
}

run "valid_inputs_configure_database_and_output" {
  command = plan

  assert {
    condition     = postgresql_database.this.name == "unit_db"
    error_message = "Database name should come from database_name."
  }

  assert {
    condition     = postgresql_database.this.owner == "unit_owner"
    error_message = "Database owner should come from database_owner."
  }

  assert {
    condition     = output.database_name == "unit_db"
    error_message = "database_name output should expose the database name."
  }
}

run "defaults_configure_database_options" {
  command = plan

  assert {
    condition     = postgresql_database.this.template == "template0"
    error_message = "Database template should be template0."
  }

  assert {
    condition     = postgresql_database.this.lc_collate == "C"
    error_message = "Database lc_collate should be C."
  }

  assert {
    condition     = postgresql_database.this.allow_connections == true
    error_message = "Database should allow connections."
  }
}

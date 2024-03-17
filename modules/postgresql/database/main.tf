terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21.0"
    }

  }
}

resource "postgresql_database" "this" {
  name              = var.database_name
  owner             = var.database_owner
  template          = "template0" # default
  lc_collate        = "C"         # default
  connection_limit  = -1          # means no limit
  allow_connections = true
}
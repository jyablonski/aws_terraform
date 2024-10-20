terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.23.0"
    }

  }
}

resource "postgresql_role" "this" {
  name      = var.role_name
  login     = true
  superuser = false
  password  = var.role_password
}
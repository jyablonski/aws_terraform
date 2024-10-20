terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.23.0"
    }

  }
}

# god damn this was a motherfucker to build.
# you create the schema
# then you need 3 sets of blocks for permissions yeet baby:
#   1. for xyz permissions on CURRENT tables in the schema
#   2. for xyz permissions on FUTURE tables in the schema
#   3. for USAGE permissions on the schema in general

resource "postgresql_schema" "this" {
  name     = var.schema_name
  database = var.database_name

}

resource "postgresql_grant" "read_only_access_grant" {
  for_each = toset(var.read_access_roles)

  database    = var.database_name
  role        = each.value
  schema      = postgresql_schema.this.name
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_grant" "read_only_access_grant_usage" {
  for_each = toset(var.read_access_roles)

  database    = var.database_name
  role        = each.value
  schema      = postgresql_schema.this.name
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_default_privileges" "read_only_access_grant_future" {
  for_each = toset(var.read_access_roles)

  role        = each.value
  database    = var.database_name
  schema      = postgresql_schema.this.name
  owner       = var.schema_owner
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_grant" "write_access_grant" {
  for_each = toset(var.write_access_roles)

  database    = var.database_name
  role        = each.value
  schema      = postgresql_schema.this.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE"]
}

resource "postgresql_grant" "write_access_grant_usage" {
  for_each = toset(var.write_access_roles)

  database    = var.database_name
  role        = each.value
  schema      = postgresql_schema.this.name
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}


resource "postgresql_default_privileges" "write_access_grant_future" {
  for_each = toset(var.write_access_roles)

  role        = each.value
  database    = var.database_name
  schema      = postgresql_schema.this.name
  owner       = var.schema_owner
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE"]
}

resource "postgresql_grant" "admin_access_grant" {
  for_each = nonsensitive(toset(var.admin_access_roles))

  database    = var.database_name
  role        = each.value
  schema      = postgresql_schema.this.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "TRIGGER", "REFERENCES"]
}

resource "postgresql_grant" "admin_access_grant_usage" {
  for_each = nonsensitive(toset(var.admin_access_roles))

  database    = var.database_name
  role        = each.value
  schema      = postgresql_schema.this.name
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}

resource "postgresql_default_privileges" "admin_access_grant_future" {
  for_each = nonsensitive(toset(var.admin_access_roles))

  role        = each.value
  database    = var.database_name
  schema      = postgresql_schema.this.name
  owner       = var.schema_owner
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "TRIGGER", "REFERENCES"]
}

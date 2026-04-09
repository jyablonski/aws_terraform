terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "1.0.5"
    }

  }
}

resource "snowflake_schema" "this" {
  database = var.db_name
  name     = var.schema_name
  comment  = var.schema_comment

  is_transient                = var.schema_is_transient
  with_managed_access         = var.schema_is_managed
  data_retention_time_in_days = var.schema_retention_days
}

# admin user
resource "snowflake_grant_privileges_to_account_role" "ownership_privileges" {
  for_each = toset(var.schema_admin_roles)

  account_role_name = each.value

  on_schema {
    schema_name = snowflake_schema.this.fully_qualified_name
  }

  all_privileges    = true
  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "ownership_privileges_future_tables" {
  for_each = toset(var.schema_admin_roles)

  account_role_name = each.value

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  all_privileges    = true
  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "ownership_privileges_future_views" {
  for_each = toset(var.schema_admin_roles)

  account_role_name = each.value

  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  all_privileges    = true
  with_grant_option = false
}

# write user
resource "snowflake_grant_privileges_to_account_role" "write_privileges_on_schema" {
  for_each = toset(var.schema_write_roles)

  account_role_name = each.value
  # , "CREATE MATERIALIZED VIEW" bug ?
  privileges = ["CREATE TABLE", "CREATE VIEW", "USAGE"]

  on_schema {
    schema_name = snowflake_schema.this.fully_qualified_name
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "write_privileges_tables" {
  for_each = toset(var.schema_write_roles)

  account_role_name = each.value
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "write_privileges_views" {
  for_each = toset(var.schema_write_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "write_privileges_materialized_views" {
  for_each = toset(var.schema_write_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "MATERIALIZED VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "future_write_privileges_tables" {
  for_each = toset(var.schema_write_roles)

  account_role_name = each.value
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "future_write_privileges_views" {
  for_each = toset(var.schema_write_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "future_write_privileges_materialized_views" {
  for_each = toset(var.schema_write_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "MATERIALIZED VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "select_privileges_on_schema" {
  for_each = toset(var.schema_read_roles)

  account_role_name = each.value
  privileges        = ["USAGE"]

  on_schema {
    schema_name = snowflake_schema.this.fully_qualified_name
  }

  with_grant_option = false
}

# read user
resource "snowflake_grant_privileges_to_account_role" "read_privileges_tables" {
  for_each = toset(var.schema_read_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "read_privileges_views" {
  for_each = toset(var.schema_read_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "read_privileges_materialized_views" {
  for_each = toset(var.schema_read_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "MATERIALIZED VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "future_read_privileges_tables" {
  for_each = toset(var.schema_read_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "future_read_privileges_views" {
  for_each = toset(var.schema_read_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_account_role" "future_read_privileges_materialized_views" {
  for_each = toset(var.schema_read_roles)

  account_role_name = each.value
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "MATERIALIZED VIEWS"
      in_schema          = snowflake_schema.this.fully_qualified_name
    }
  }

  with_grant_option = false
}

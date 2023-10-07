terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.72"
    }
    snowsql = {
      source  = "aidanmelen/snowsql"
      version = "~> 1.0"
    }

  }
}

resource "snowflake_schema" "this" {
  # tflint-ignore: all
  database = var.db_name
  name     = var.schema_name
  comment  = var.schema_comment

  is_transient        = var.schema_is_transient
  is_managed          = var.schema_is_managed
  data_retention_days = var.schema_retention_days
}

resource "snowsql_exec" "this_select" {

  for_each = toset(var.schema_read_roles)

  name = "${each.key}_select_grant"

  create {
    statements = <<-EOT
    GRANT USAGE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT SELECT ON ALL TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT SELECT ON ALL VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT SELECT ON FUTURE TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT SELECT ON FUTURE VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    EOT
  }

  delete {
    statements = <<-EOT
    REVOKE USAGE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE SELECT ON ALL TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE SELECT ON ALL VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE SELECT ON FUTURE TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE SELECT ON FUTURE VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE SELECT ON FUTURE MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    EOT
  }
}

resource "snowsql_exec" "this_all" {
  # tflint-ignore: all

  for_each = toset(var.schema_all_roles)

  name = "${each.key}_all_grant"

  create {
    statements = <<-EOT
    GRANT USAGE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT CREATE TABLE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT CREATE VIEW ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT CREATE PROCEDURE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT ALL ON ALL TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT ALL ON ALL VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT ALL ON ALL MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT ALL ON FUTURE TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT ALL ON FUTURE VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    GRANT ALL ON FUTURE MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} TO ROLE ${each.key};
    EOT
  }

  delete {
    statements = <<-EOT
    REVOKE USAGE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE CREATE TABLE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE CREATE VIEW ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE CREATE PROCEDURE ON SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE ALL ON ALL TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE ALL ON ALL VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE ALL ON ALL MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE ALL ON FUTURE TABLES IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE ALL ON FUTURE VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    REVOKE ALL ON FUTURE MATERIALIZED VIEWS IN SCHEMA ${var.db_name}.${snowflake_schema.this.name} FROM ROLE ${each.key};
    EOT
  }
}
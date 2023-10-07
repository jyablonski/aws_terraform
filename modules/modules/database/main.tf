resource "snowflake_database" "module_db" {
  name                        = var.db_name
  comment                     = var.db_comment
  data_retention_time_in_days = var.db_retention_time
  is_transient                = var.db_is_transient
}

resource "snowflake_database_grant" "module_grant_db_ownership" {
  count = var.db_ownership_access ? 1 : 0

  database_name          = snowflake_database.module_db.name
  enable_multiple_grants = true

  privilege = "OWNERSHIP"
  roles     = var.db_ownership_roles

  with_grant_option = false
}

# resource "snowflake_database_grant" "module_grant_db_write" {
#   count = var.db_write_access ? 1 : 0

#   database_name          = snowflake_database.module_db.name
#   enable_multiple_grants = true

#   privilege = "INSERT"
#   roles     = [var.db_write_roles]

#   with_grant_option = false
# }

# resource "snowflake_database_grant" "module_grant_db_write_select" {
#   count = var.db_write_access ? 1 : 0

#   database_name          = snowflake_database.module_db.name
#   enable_multiple_grants = true

#   privilege = "SELECT"
#   roles     = [var.db_write_roles]

#   with_grant_option = false
# }

resource "snowflake_database_grant" "module_grant_db_write_usage" {
  count = var.db_access ? 1 : 0

  database_name          = snowflake_database.module_db.name
  enable_multiple_grants = true

  privilege = "USAGE"
  roles     = var.db_access_roles

  with_grant_option = false
}


# resource "snowflake_database_grant" "module_grant_db_read" {
#   count = var.db_read_access ? 1 : 0

#   database_name          = snowflake_database.module_db.name
#   enable_multiple_grants = true

#   privilege = "SELECT"
#   roles     = [var.db_read_roles]

#   with_grant_option = false
# }

# resource "snowflake_database_grant" "module_grant_db_read_usage" {
#   count = var.db_read_access ? 1 : 0

#   database_name          = snowflake_database.module_db.name
#   enable_multiple_grants = true

#   privilege = "USAGE"
#   roles     = [var.db_read_roles]

#   with_grant_option = false
# }
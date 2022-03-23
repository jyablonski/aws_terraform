# resource "postgresql_role" "jacob_admin" {
#   name      = "jacob_admin"
#   login     = true
#   superuser = true
#   password  = var.pg_pass
# }

# ### DEV
# resource "postgresql_database" "nba_db_dev" {
#   provider = postgresql.pg1
#   name     = "nba_elt_pipeline_db_dev"
# }

# resource "postgresql_role" "dbt_dev" {
#   name = "dbt_dev"
# }

# resource "postgresql_role" "python_scrape_dev" {
#   name = "python_scrape_dev"
# }

# resource "postgresql_role" "shiny_read_dev" {
#   name = "shiny_read_dev"
# }

# resource "postgresql_schema" "nba_source_dev" {
#   name     = "nba_source_dev"
#   owner    = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_dev.name

#   policy {
#     usage = true
#     role  = postgresql_role.dbt_dev.name
#   }

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.python_scrape_dev.name
#   }

#   policy {
#     create_with_grant = true
#     usage_with_grant  = true
#     role              = postgresql_role.jacob_admin.name
#   }
# }

# resource "postgresql_schema" "nba_staging_dev" {
#   name     = "nba_staging_dev"
#   owner    = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_dev.name

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.dbt_dev.name
#   }

#   policy {
#     create_with_grant = true
#     usage_with_grant  = true
#     role              = postgresql_role.jacob_admin.name
#   }
# }

# resource "postgresql_schema" "nba_prep_dev" {
#   name  = "nba_prep_dev"
#   owner = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_dev.name

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.dbt_dev.name
#   }

#   policy {
#     create_with_grant = true
#     usage_with_grant  = true
#     role              = postgresql_role.jacob_admin.name
#   }
# }

# resource "postgresql_schema" "nba_ml_dev" {
#   name  = "nba_ml_dev"
#   owner = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_dev.name

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.dbt_dev.name
#   }

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.python_scrape_dev.name
#   }

#   policy {
#     create_with_grant = true
#     usage_with_grant  = true
#     role              = postgresql_role.jacob_admin.name
#   }
# }

# resource "postgresql_schema" "nba_operations_dev" {
#   name  = "nba_operations_dev"
#   owner = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_dev.name

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.dbt_dev.name
#   }

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.python_scrape_dev.name
#   }

#   policy {
#     create_with_grant = true
#     usage_with_grant  = true
#     role              = postgresql_role.jacob_admin.name
#   }
# }

# resource "postgresql_schema" "nba_marts_dev" {
#   name  = "nba_marts_dev"
#   owner = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_dev.name

#   policy {
#     usage = true
#     role  = postgresql_role.shiny_read_dev.name
#   }

#   policy {
#     create = true
#     usage  = true
#     role   = postgresql_role.dbt_dev.name
#   }

#   policy {
#     create_with_grant = true
#     usage_with_grant  = true
#     role              = postgresql_role.jacob_admin.name
#   }
# }


### PROD
# resource "postgresql_database" "nba_db_prod" {
#   provider = "postgresql.pg1"
#   name     = "nba_elt_pipeline_db_prod"
# }

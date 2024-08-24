# resource "postgresql_role" "jacob_admin" {
#   name      = "jacob_admin"
#   login     = true
#   superuser = true
#   password  = var.pg_pass
# }

### DEV
# resource "postgresql_database" "nba_db_prod" {
#   # provider = postgresql.pg1
#   name = "nba_elt_pipeline_db"
# }

# resource "postgresql_role" "dbt_role" {
#   name     = "dbt_role"
#   password = "${var.pg_role_pass}dbt"
# }

# resource "postgresql_role" "python_scrape_role" {
#   name     = "python_scrape_role"
#   password = "${var.pg_role_pass}python"
# }

# resource "postgresql_role" "shiny_read_role" {
#   name     = "shiny_read_role"
#   password = "${var.pg_role_pass}shiny"
# }

# resource "postgresql_role" "rest_api_read_role" {
#   name     = "rest_api_read_role"
#   password = "${var.pg_role_pass}restapi"
# }

# resource "postgresql_schema" "nba_source" {
#   name = "nba_source"
#   # owner    = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_prod.name

# }

# resource "postgresql_schema" "nba_prod" {
#   name = "nba_prod"
#   # owner    = postgresql_role.jacob_admin.name
#   database = postgresql_database.nba_db_prod.name

# }

# resource "postgresql_grant" "rest_api_read_access" {
#   database          = postgresql_database.nba_db_prod.name
#   role              = postgresql_role.rest_api_read_role.name
#   schema            = postgresql_schema.nba_prod.name
#   object_type       = "table"
#   objects           = [] # read access to everything in this schema.
#   privileges        = ["SELECT"]
#   with_grant_option = false
# }

# resource "postgresql_grant" "shiny_read_access" {
#   database          = postgresql_database.nba_db_prod.name
#   role              = postgresql_role.shiny_read_role.name
#   schema            = postgresql_schema.nba_prod.name
#   object_type       = "table"
#   objects           = [] # read access to everything in this schema.
#   privileges        = ["SELECT"]
#   with_grant_option = false
# }

# resource "postgresql_schema" "ml_models" {
#   name     = "ml_models"
#   database = postgresql_database.nba_db_prod.name
# }

# resource "postgresql_grant" "shiny_read_access_ml" {
#   database          = postgresql_database.nba_db_prod.name
#   role              = postgresql_role.shiny_read_role.name
#   schema            = postgresql_schema.ml_models.name
#   object_type       = "table"
#   objects           = [] # read access to everything in this schema.
#   privileges        = ["SELECT"]
#   with_grant_option = false
# }

# resource "postgresql_schema" "ad_hoc_analytics" {
#   name     = "ad_hoc_analytics"
#   database = postgresql_database.nba_db_prod.name
# }

# resource "postgresql_schema" "nba_prep" {
#   name     = "nba_prep"
#   database = postgresql_database.nba_db_prod.name
# }

# resource "postgresql_schema" "nba_prod_jy" {
#   name     = "nba_prod_jy"
#   database = postgresql_database.nba_db_prod.name
# }

# resource "postgresql_schema" "nba_staging" {
#   name     = "nba_staging"
#   database = postgresql_database.nba_db_prod.name
# }

# resource "postgresql_schema" "operations" {
#   name     = "operations"
#   database = postgresql_database.nba_db_prod.name
# }

# resource "postgresql_schema" "snapshots" {
#   name     = "snapshots"
#   database = postgresql_database.nba_db_prod.name
# }
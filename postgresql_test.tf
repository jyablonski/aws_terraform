# 2024-01-30 - got this mf working baby
# swap to this during next aws account swap to setup all rds infra
# module "postgres_db" {
#   source = "./modules/postgresql/database"

#   database_name  = "jacob_tester"
#   database_owner = var.jacobs_rds_user
# }

# module "postgres_read" {
#   source        = "./modules/postgresql/role"
#   role_name     = "tester"
#   role_password = var.es_master_pw
# }


# module "reporting_schema" {
#   source = "./modules/postgresql/schema"

#   schema_name   = "reporting"
#   database_name = var.jacobs_rds_db
#   schema_owner  = var.jacobs_rds_user

#   read_access_roles  = ["nba_dashboard_user", module.postgres_read.role_name]
#   write_access_roles = []
#   admin_access_roles = [var.jacobs_rds_user]
# }

# module "postgres_admin" {
#   source        = "./modules/postgresql/role"
#   role_name     = ""
#   role_password = ""
# }

# module "postgres_read" {
#   source        = "./modules/postgresql/role"
#   role_name     = ""
#   role_password = ""
# }


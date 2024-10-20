# 2024-01-30 - got this mf working baby
# swap to this during next aws account swap to setup all rds infra
# module "postgres_db" {
#   source = "./modules/postgresql/database"

#   database_name  = "jacob_tester"
#   database_owner = var.jacobs_rds_user
# }

module "dbt_role_prod" {
  source        = "./modules/postgresql/role"
  role_name     = "dbt_role_prod"
  role_password = "${var.es_master_pw}dbt"
}

module "rest_api_role_prod" {
  source        = "./modules/postgresql/role"
  role_name     = "rest_api_role_prod"
  role_password = "${var.es_master_pw}api"
}

module "dash_role_prod" {
  source        = "./modules/postgresql/role"
  role_name     = "dash_role_prod"
  role_password = "${var.es_master_pw}dash"
}

module "ingestion_role_prod" {
  source        = "./modules/postgresql/role"
  role_name     = "ingestion_role_prod"
  role_password = "${var.es_master_pw}ingestion"
}

module "ml_role_prod" {
  source        = "./modules/postgresql/role"
  role_name     = "ml_role_prod"
  role_password = "${var.es_master_pw}ml"
}


module "reporting_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "reporting"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = [module.rest_api_role_prod.role_name, module.dash_role_prod.role_name]
  write_access_roles = [module.dbt_role_prod.role_name]
  admin_access_roles = [var.postgres_username]
}

module "source_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "nba_source"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = [module.dbt_role_prod.role_name]
  write_access_roles = [module.ingestion_role_prod.role_name]
  admin_access_roles = [var.postgres_username]
}

module "marts_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "marts"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = [module.dash_role_prod.role_name, module.ml_role_prod.role_name]
  write_access_roles = [module.rest_api_role_prod.role_name]
  admin_access_roles = [var.postgres_username, module.dbt_role_prod.role_name]
}

module "ml_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "ml"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = [module.rest_api_role_prod.role_name, module.dash_role_prod.role_name]
  write_access_roles = [module.ml_role_prod.role_name, module.dbt_role_prod.role_name]
  admin_access_roles = [var.postgres_username]
}

module "prep_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "prep"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = []
  write_access_roles = []
  admin_access_roles = [var.postgres_username, module.dbt_role_prod.role_name]
}

module "fact_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "fact"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = []
  write_access_roles = []
  admin_access_roles = [var.postgres_username, module.dbt_role_prod.role_name]
}

module "dim_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "dim"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = []
  write_access_roles = []
  admin_access_roles = [var.postgres_username, module.dbt_role_prod.role_name]
}

module "ad_hoc_analytics_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "ad_hoc_analytics"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = []
  write_access_roles = []
  admin_access_roles = [module.dbt_role_prod.role_name]
}

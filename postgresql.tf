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

module "bronze_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "bronze"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = [module.dbt_role_prod.role_name]
  write_access_roles = [module.ingestion_role_prod.role_name]
  admin_access_roles = [var.postgres_username]
}

module "silver_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "silver"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = [module.ml_role_prod.role_name]
  write_access_roles = []
  admin_access_roles = [var.postgres_username, module.dbt_role_prod.role_name]
}

module "gold_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "gold"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  # ingestion role needs to query the feature flags table, which is currently in gold schema
  read_access_roles = [module.dash_role_prod.role_name, module.ingestion_role_prod.role_name]

  # the ml and rest api roles need write access to update model results and predictions for 
  # models in the gold layer
  write_access_roles = [module.rest_api_role_prod.role_name, module.ml_role_prod.role_name]
  admin_access_roles = [var.postgres_username, module.dbt_role_prod.role_name]
}

module "scratch_schema" {
  source = "./modules/postgresql/schema"

  schema_name   = "scratch"
  database_name = var.jacobs_rds_db
  schema_owner  = var.postgres_username

  read_access_roles  = []
  write_access_roles = []
  admin_access_roles = [var.postgres_username, module.dbt_role_prod.role_name]
}

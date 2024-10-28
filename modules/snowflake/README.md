# Snowflake Modules


## Example Usage

`main.tf` File
``` tf
module "snowflake_storage" {
  source                      = "./modules/storage_integration"
  storage_integration_name    = "S3_STORAGE_INTEGRATION"
  storage_integration_comment = "Storage integration for S3"

  bucket_name               = "jyablonski-nba-elt-prod"
  storage_allowed_locations = "*"
  storage_blocked_locations = "s3://s3-fake"
  # snowflake_integration_user_roles = ["ACCOUNTADMIN"]
  iam_role_name  = "snowflake_integration_role"
  aws_account_id = 509399594058

}

module "airflow_role_prod" {
  source = "./modules/role"
  role_name = "AIRFLOW_ROLE_PROD"
  role_comment = "Role for AIRFLOW_ROLE_PROD"
  role_warehouse_size = "XSMALL"
}


module "prod_database" {
  source             = "./modules/database"
  db_name            = "PRODUCTION"
  db_retention_time  = 1
  db_is_transient    = false
  db_ownership_roles = ["ACCOUNTADMIN"]
  db_access_roles    = [module.airflow_role_prod.role_name]

}

module "test_schema" {
  source  = "./modules/schema"
  db_name = module.prod_database.db_name

  schema_name           = "TEST_SCHEMA"
  schema_comment        = "Test schema"
  schema_is_transient   = false
  schema_is_managed     = false
  schema_retention_days = 1
  schema_admin_roles    = ["ACCOUNTADMIN"]
  schema_write_roles    = [module.airflow_role_prod.role_name]
  schema_read_roles     = []
}


```

`terraform.tfvars` File
``` tfvars
snowflake_username = "terraform_user"
snowflake_password = "aaa!"
snowflake_account  = "AFAZVKL-QGB24430"
region = "us-east-1"
access_key = "aaa"
secret_key = "bbb"

```
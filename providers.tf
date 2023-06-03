provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

  default_tags {
    tags = {
      Owner = "jacob"
      # environment = "prod"
      # last_modified_by = "jyablonski"
      # last_modified_by_aws_id = "${data.aws_caller_identity.current.arn}"
      # updated_at = timestamp()
      # project = "nba_pipeline"
      # is_terraform = true
    }
  }
}

# 2022-06-24 reminder:
# https://learn.hashicorp.com/tutorials/terraform/aws-default-tags
# implement default tags when deploying infra next august pls
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
    # snowflake = {
    #   source  = "Snowflake-Labs/snowflake"
    #   version = "0.51.0"
    # }
    # snowsql = {
    #   source  = "aidanmelen/snowsql"
    #   version = "1.0.1"

  }
  cloud {
    organization = "jyablonski_prac"
    workspaces {
      name = "github-terraform-demo"
    }
  }

}

provider "postgresql" {
  # alias    = "pg1" - this fucks shit up for some reason yo
  host     = var.pg_host
  username = var.pg_user
  password = var.pg_pass
  sslmode  = "disable"
}

# provider "snowflake" {
#   username    = var.snowflake_username
#   account     = var.snowflake_account
#   region      = var.snowflake_region
#   private_key = var.private_key_path
#   role        = var.snowflake_role
# }

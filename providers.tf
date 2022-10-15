provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

  default_tags {
    tags = {
      Owner = "jacob"
      # last_modified_by = "jyablonski"
      # updated_at = timestamp()
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
      version = "4.24.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
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
#   username = var.snowflake_user
#   account  = "rl64113"
#   region   = "us-east-2.aws"
#   password = var.snowflake_pw
# }
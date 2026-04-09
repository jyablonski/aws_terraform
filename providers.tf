provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

  default_tags {
    tags = local.common_tags
  }
}

# 2022-06-24 reminder:
# https://learn.hashicorp.com/tutorials/terraform/aws-default-tags
# implement default tags when deploying infra next august pls
terraform {
  required_version = ">= 1.9.6, < 2.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Hold on AWS provider v5 for now; v6 is a larger migration.
      version = ">= 5.72.1, < 6.0.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.26.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.0"
    }
    # snowflake = {
    #   source  = "Snowflake-Labs/snowflake"
    #   version = "~> 0.96.0"
    # }

    # you'd use this to store secrets using SOPS + KMS
    # sops = {
    #   source  = "carlpett/sops"
    #   version = "~> 1.3"
    # }

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
  host            = var.postgres_host
  username        = var.postgres_username
  password        = var.postgres_password
  port            = 17841
  superuser       = false
  connect_timeout = 15
  sslmode         = "require"
  database        = var.jacobs_rds_db
}

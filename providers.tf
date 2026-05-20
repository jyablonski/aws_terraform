provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

# 2022-06-24 reminder:
# https://learn.hashicorp.com/tutorials/terraform/aws-default-tags
# implement default tags when deploying infra next august pls
terraform {
  required_version = ">= 1.15.2, < 2.0.0"
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
  }

  backend "s3" {
    bucket       = "jyablonski-aws-terraform-state-326614947945"
    key          = "aws_terraform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
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

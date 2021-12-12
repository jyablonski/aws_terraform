provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.14.0"
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
  host     = var.pg_host
  username = var.pg_user
  password = var.pg_pass
}
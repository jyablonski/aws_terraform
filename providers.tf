provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    snowflake = {
      source = "chanzuckerberg/snowflake"
      version = "0.25.30"
    }
  }
    cloud {
      organization = "jyablonski_prac"
      workspaces {
        name = "github-terraform-demo"
      }
  }
}
provider "snowflake" {
  username = var.snowflake_user
  account  = "rl64113"
  region   = "us-east-2"
  password = var.snowflake_pw
}
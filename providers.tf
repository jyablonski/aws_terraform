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
  required_version = "1.9.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.23.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3.0"
    }
    # snowflake = {
    #   source  = "Snowflake-Labs/snowflake"
    #   version = "~> 0.96.0"
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

# provider "snowflake" {
#   account  = var.snowflake_account
#   user     = var.snowflake_username
#   password = var.snowflake_password
#   role     = "ACCOUNTADMIN"
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.default.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.default.token
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.default.endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.default.token

# exec {
#   api_version = "client.authentication.k8s.io/v1beta1"
#   command     = "aws"
#   # This requires the awscli to be installed locally where Terraform is executed
#   args = ["eks", "get-token", "--cluster-name", "jacobs-eks-cluster", "--region", "us-east-1"]
# }
# }

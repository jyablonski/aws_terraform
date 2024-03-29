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
  required_version = "1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3.0"
    }
    # snowflake = {
    #   source  = "Snowflake-Labs/snowflake"
    #   version = "0.51.0"
    # }
    # snowsql = {
    #   source  = "aidanmelen/snowsql"
    #   version = "1.0.1"
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
  host      = var.pg_host
  username  = var.pg_user
  password  = var.pg_pass
  sslmode   = "disable"
  superuser = false
}

# provider "snowflake" {
#   username    = var.snowflake_username
#   account     = var.snowflake_account
#   region      = var.snowflake_region
#   private_key = var.private_key_path
#   role        = var.snowflake_role
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

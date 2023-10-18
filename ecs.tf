locals {
  module_dbt_logs       = "jacobs_ecs_logs_dbt"
  module_webscrape_logs = "jacobs_ecs_logs"
  module_ml_logs        = "jacobs_ecs_logs_ml"
  module_fake_logs      = "jacobs_ecs_logs_fake_ecs"
  module_airflow_logs   = "jacobs_ecs_logs_airflow"
  module_dash_logs      = "jacobs_ecs_logs_dash"
  module_shiny_logs     = "jacobs_ecs_logs_shiny"
}

resource "aws_ecr_repository" "jacobs_repo" {
  name                 = "jacobs_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "jacobs_repo_policy" {
  repository = aws_ecr_repository.jacobs_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Remove Untagged Images after 1 Day",
            "selection": {
              "tagStatus": "untagged",
              "countType": "sinceImagePushed",
              "countUnit": "days",
              "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecs_cluster" "jacobs_ecs_cluster" {
  name = "jacobs_fargate_cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

module "webscrape_ecs_module" {
  source                   = "./modules/ecs"
  ecs_schedule             = false
  ecs_id                   = "jacobs_webscrape_task"
  ecs_container_definition = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:latest",
        "name": "jacobs_container",
        "environment": [
          {"name": "IP", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "PORT", "value": "5432"},
          {"name": "RDS_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "RDS_PW", "value": "${var.jacobs_rds_pw}"},
          {"name": "RDS_SCHEMA", "value": "${var.jacobs_rds_schema}"},
          {"name": "RDS_DB", "value": "jacob_db"},
          {"name": "reddit_user", "value": "${var.jacobs_reddit_user}"},
          {"name": "reddit_pw", "value": "${var.jacobs_reddit_pw}"},
          {"name": "reddit_accesskey", "value": "${var.jacobs_reddit_accesskey}"},
          {"name": "reddit_secretkey", "value": "${var.jacobs_reddit_secretkey}"},
          {"name": "USER_PW", "value": "${var.jacobs_pw}"},
          {"name": "USER_EMAIL", "value": "${var.jacobs_email_address}"},
          {"name": "S3_BUCKET", "value": "${aws_s3_bucket.jacobs_bucket_tf.bucket}"},
          {"name": "SENTRY_TOKEN", "value": "${var.jacobs_sentry_token}"},
          {"name": "twitter_consumer_api_key", "value": "${var.jacobs_twitter_key}"},
          {"name": "twitter_consumer_api_secret", "value": "${var.jacobs_twitter_secret}"},
          {"name": "WEBHOOK_URL", "value": "${var.ingestion_webhook_url}"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${local.module_webscrape_logs}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  ecs_execution_role_arn   = aws_iam_role.jacobs_ecs_role.arn
  ecs_task_role_arn        = aws_iam_role.jacobs_ecs_role.arn
  ecs_cpu                  = 256
  ecs_memory               = 512

  ecs_logs_name      = local.module_webscrape_logs
  ecs_logs_retention = 30

  ecs_rule_name        = "jacobs_webscrape_rule"
  ecs_rule_description = "Run every day at 11 am UTC"
  ecs_rule_cron        = "cron(0 11 * * ? *)"

  ecs_cluster_id        = aws_ecs_cluster.jacobs_ecs_cluster.arn
  ecs_target_id         = "jacobs_webscrape_target"
  ecs_ecr_role          = aws_iam_role.jacobs_ecs_ecr_role.arn
  ecs_subnet_1          = aws_subnet.jacobs_public_subnet.id
  ecs_subnet_2          = aws_subnet.jacobs_public_subnet_2.id
  ecs_security_group_id = aws_security_group.jacobs_task_security_group_tf.id
}

module "dbt_ecs_module" {
  source                   = "./modules/ecs"
  ecs_schedule             = false
  ecs_id                   = "jacobs_dbt_task"
  ecs_container_definition = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:nba_elt_pipeline_dbt",
        "name": "jacobs_container_dbt",
        "environment": [
          {"name": "DBT_DBNAME", "value": "${var.jacobs_rds_db}"},
          {"name": "DBT_HOST", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "DBT_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "DBT_PASS", "value": "${var.jacobs_rds_pw}"},
          {"name": "DBT_SCHEMA", "value": "${var.jacobs_rds_schema}"},
          {"name": "DBT_PRAC_KEY", "value": "dbt_docker_test"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${local.module_dbt_logs}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  ecs_execution_role_arn   = aws_iam_role.jacobs_ecs_role.arn
  ecs_task_role_arn        = aws_iam_role.jacobs_ecs_role.arn
  ecs_cpu                  = 256
  ecs_memory               = 512

  ecs_logs_name      = local.module_dbt_logs
  ecs_logs_retention = 7

  ecs_rule_name        = "jacobs_dbt_rule"
  ecs_rule_description = "Run everyday at 11:15 AM UTC"
  ecs_rule_cron        = "cron(15 11 * * ? *)"

  ecs_cluster_id        = aws_ecs_cluster.jacobs_ecs_cluster.arn
  ecs_target_id         = "jacobs_dbt_target"
  ecs_ecr_role          = aws_iam_role.jacobs_ecs_ecr_role.arn
  ecs_subnet_1          = aws_subnet.jacobs_public_subnet.id
  ecs_subnet_2          = aws_subnet.jacobs_public_subnet_2.id
  ecs_security_group_id = aws_security_group.jacobs_task_security_group_tf.id
}

module "ml_ecs_module" {
  source                   = "./modules/ecs"
  ecs_schedule             = false
  ecs_id                   = "jacobs_ml_task"
  ecs_container_definition = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:nba_elt_ml",
        "name": "jacobs_container_ml",
        "environment": [
          {"name": "IP", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "PORT", "value": "5432"},
          {"name": "RDS_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "RDS_PW", "value": "${var.jacobs_rds_pw}"},
          {"name": "RDS_SCHEMA", "value": "${var.jacobs_rds_schema_ml}"},
          {"name": "RDS_DB", "value": "jacob_db"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${local.module_ml_logs}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  ecs_execution_role_arn   = aws_iam_role.jacobs_ecs_role.arn
  ecs_task_role_arn        = aws_iam_role.jacobs_ecs_role.arn
  ecs_cpu                  = 256
  ecs_memory               = 512

  ecs_logs_name      = local.module_ml_logs
  ecs_logs_retention = 30

  ecs_rule_name        = "jacobs_ml_rule"
  ecs_rule_description = "Run everyday at 11:30 AM"
  ecs_rule_cron        = "cron(30 11 * * ? *)"

  ecs_cluster_id        = aws_ecs_cluster.jacobs_ecs_cluster.arn
  ecs_target_id         = "jacobs_ml_target"
  ecs_ecr_role          = aws_iam_role.jacobs_ecs_ecr_role.arn
  ecs_subnet_1          = aws_subnet.jacobs_public_subnet.id
  ecs_subnet_2          = aws_subnet.jacobs_public_subnet_2.id
  ecs_security_group_id = aws_security_group.jacobs_task_security_group_tf.id
}

module "fake_ecs_module" {
  source                   = "./modules/ecs"
  ecs_schedule             = false
  ecs_id                   = "jacobs_fake_task"
  ecs_container_definition = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:fake_ecs_task",
        "name": "jacobs_container_fake",
        "environment": [
          {"name": "test", "value": "test1"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${local.module_fake_logs}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  ecs_execution_role_arn   = aws_iam_role.jacobs_ecs_role.arn
  ecs_task_role_arn        = aws_iam_role.jacobs_ecs_role.arn
  ecs_cpu                  = 256
  ecs_memory               = 512

  ecs_logs_name      = local.module_fake_logs
  ecs_logs_retention = 7

  ecs_rule_name        = "jacobs_fake_rule"
  ecs_rule_description = "First Module Test - run everyday at 3 AM"
  ecs_rule_cron        = "cron(0 3 * * ? *)"

  ecs_cluster_id        = aws_ecs_cluster.jacobs_ecs_cluster.arn
  ecs_target_id         = "jacobs_fake_target"
  ecs_ecr_role          = aws_iam_role.jacobs_ecs_ecr_role.arn
  ecs_subnet_1          = aws_subnet.jacobs_public_subnet.id
  ecs_subnet_2          = aws_subnet.jacobs_public_subnet_2.id
  ecs_security_group_id = aws_security_group.jacobs_task_security_group_tf.id
}

module "airflow_ecs_module" {
  source                   = "./modules/ecs"
  ecs_schedule             = false
  ecs_id                   = "jacobs_airflow_task"
  ecs_container_definition = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:nba_airflow",
        "name": "jacobs_container_airflow",
        "environment": [
          {"name": "IP", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "PORT", "value": "5432"},
          {"name": "RDS_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "RDS_PW", "value": "${var.jacobs_rds_pw}"},
          {"name": "RDS_DB", "value": "jacob_db"},
          {"name": "reddit_user", "value": "${var.jacobs_reddit_user}"},
          {"name": "reddit_pw", "value": "${var.jacobs_reddit_pw}"},
          {"name": "reddit_accesskey", "value": "${var.jacobs_reddit_accesskey}"},
          {"name": "reddit_secretkey", "value": "${var.jacobs_reddit_secretkey}"},
          {"name": "USER_PW", "value": "${var.jacobs_pw}"},
          {"name": "USER_EMAIL", "value": "${var.jacobs_email_address}"},
          {"name": "S3_BUCKET", "value": "${var.jacobs_bucket}"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${local.module_airflow_logs}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  ecs_execution_role_arn   = aws_iam_role.jacobs_ecs_role.arn
  ecs_task_role_arn        = aws_iam_role.jacobs_ecs_role.arn
  ecs_cpu                  = 256
  ecs_memory               = 512

  ecs_logs_name      = local.module_airflow_logs
  ecs_logs_retention = 30

  ecs_rule_name        = "jacobs_airflow_rule"
  ecs_rule_description = "First Module Test - run everyday at 3 AM"
  ecs_rule_cron        = "cron(0 3 * * ? *)"

  ecs_cluster_id        = aws_ecs_cluster.jacobs_ecs_cluster.arn
  ecs_target_id         = "jacobs_airflow_target"
  ecs_ecr_role          = aws_iam_role.jacobs_ecs_ecr_role.arn
  ecs_subnet_1          = aws_subnet.jacobs_public_subnet.id
  ecs_subnet_2          = aws_subnet.jacobs_public_subnet_2.id
  ecs_security_group_id = aws_security_group.jacobs_task_security_group_tf.id
}

# shiny
module "shiny_ecs_module" {
  source                   = "./modules/ecs"
  ecs_network_mode         = "bridge"
  ecs_compatability        = "EC2"
  ecs_schedule             = false
  ecs_id                   = "shiny_nba_dashboard"
  ecs_container_definition = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:shiny_app",
        "name": "shiny_container",
        "environment": [
          {"name": "AWS_HOST", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "AWS_PORT", "value": "5432"},
          {"name": "AWS_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "AWS_PW", "value": "${var.jacobs_rds_pw}"},
          {"name": "AWS_DB", "value": "jacob_db"}
        ],
        "portMappings": [
          {
            "name": "shiny_app-3838-tcp",
            "containerPort": 3838,
            "hostPort": 3838,
            "protocol": "tcp",
            "appProtocol": "http"
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${local.module_shiny_logs}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  ecs_execution_role_arn   = aws_iam_role.jacobs_ecs_role.arn
  ecs_task_role_arn        = aws_iam_role.jacobs_ecs_role.arn
  ecs_cpu                  = 524
  ecs_memory               = 819

  ecs_logs_name      = local.module_shiny_logs
  ecs_logs_retention = 30

  ecs_rule_name        = "shiny_rule"
  ecs_rule_description = "First Module Test - run everyday at 3 AM"
  ecs_rule_cron        = "cron(0 3 * * ? *)"

  ecs_cluster_id        = aws_ecs_cluster.jacobs_ecs_cluster.arn
  ecs_target_id         = "shiny_target"
  ecs_ecr_role          = aws_iam_role.jacobs_ecs_ecr_role.arn
  ecs_subnet_1          = aws_subnet.jacobs_public_subnet.id
  ecs_subnet_2          = aws_subnet.jacobs_public_subnet_2.id
  ecs_security_group_id = aws_security_group.jacobs_task_security_group_tf.id
}

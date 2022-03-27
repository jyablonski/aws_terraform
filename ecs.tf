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

## STOP at this step and upload docker image to this repo.  format below
# docker tag jacobs-python-docker-2:latest 324816727452.dkr.ecr.us-east-1.amazonaws.com/jacobs_repo:latest
# docker push 324816727452.dkr.ecr.us-east-1.amazonaws.com/jacobs_repo:latest

resource "aws_cloudwatch_log_group" "aws_ecs_logs" {
  name              = "jacobs_ecs_logs"
  retention_in_days = 30

}

resource "aws_cloudwatch_log_group" "aws_ecs_logs_airflow" {
  name              = "jacobs_ecs_logs_airflow"
  retention_in_days = 30

}

resource "aws_ecs_cluster" "jacobs_ecs_cluster" {
  name = "jacobs_fargate_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# cloudwatch log stuff would go in the container defintion part with logConfiguration
resource "aws_ecs_task_definition" "jacobs_ecs_task" {
  family                   = "jacobs_task"
  container_definitions    = <<TASK_DEFINITION
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
          {"name": "S3_BUCKET", "value": "${var.jacobs_bucket}"},
          {"name": "SENTRY_TOKEN", "value": "${var.jacobs_sentry_token}"},
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "jacobs_ecs_logs",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  execution_role_arn       = aws_iam_role.jacobs_ecs_role.arn # permissions needed for pulling ecr or writing to cloudwatch logs etc
  task_role_arn            = aws_iam_role.jacobs_ecs_role.arn # the actual permissions needed for when code runs (s3 access, ses access etc)
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "jacobs_ecs_task_airflow" {
  family                   = "jacobs_task_airflow"
  container_definitions    = <<TASK_DEFINITION
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
            "awslogs-group": "jacobs_ecs_logs_airflow",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  execution_role_arn       = aws_iam_role.jacobs_ecs_role.arn # aws managed role to give permission to private ecr repo i just made.
  task_role_arn            = aws_iam_role.jacobs_ecs_role.arn
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_cloudwatch_event_rule" "every_15_mins" {
  name                = "python_scheduled_task_test" # change this name
  description         = "Run every 15 minutes"
  schedule_expression = "cron(0/15 * * * ? *)"
}

# in march change to 11 am utc
# in nov change to 12 pm utc
resource "aws_cloudwatch_event_rule" "etl_rule" {
  name                = "python_scheduled_task_prod" # change this name
  description         = "Run every day at 11 am UTC"
  schedule_expression = "cron(0 11 * * ? *)"
}


# # # uncomment the block below when nba season starts and change the rule to etl_rule instead of every_15_min
resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "jacobs_target_id"
  arn       = aws_ecs_cluster.jacobs_ecs_cluster.arn
  rule      = aws_cloudwatch_event_rule.etl_rule.name
  role_arn  = aws_iam_role.jacobs_ecs_ecr_role.arn

  ecs_target {
    launch_type = "FARGATE"
    network_configuration {
      subnets          = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id] # do not use subnet group here - wont work.  need list of the individual subnet ids.
      security_groups  = [aws_security_group.jacobs_task_security_group_tf.id]
      assign_public_ip = true
    }
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.jacobs_ecs_task.arn
  }
}
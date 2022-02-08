locals {
    ecs_task_schedule_twitch = "Jacobs Twitch Scheduled Task"
    ecs_task_name_twitch = "jacobs-twitch-ecs-task"
    ecs_logs_name_twitch = "jacobs-twitch-logs"
    ecs_task_ecr_name = "twitch_scraper"
}

resource "aws_cloudwatch_log_group" "aws_ecs_logs_twitch" {
  name              = local.ecs_logs_name_twitch
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "jacobs_ecs_task_twitch" {
  family                = local.ecs_task_name_twitch
  container_definitions = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:${local.ecs_task_ecr_name}",
        "name": "jacobs_container_twitch",
        "environment": [
          {"name": "IP", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "RDS_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "RDS_PW", "value": "${var.jacobs_rds_pw}"},
          {"name": "RDS_DB", "value": "${var.jacobs_rds_db}"},
          {"name": "RDS_SCHEMA", "value": "${var.jacobs_rds_schema_twitch}"},
          {"name": "USER_EMAIL", "value": "${var.jacobs_email_address}"},
          {"name": "client_id", "value": "${var.jacobs_client_id_twitch}"},
          {"name": "client_secret", "value": "${var.jacobs_client_secret_twitch}"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${local.ecs_logs_name_twitch}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  execution_role_arn = aws_iam_role.jacobs_ecs_role.arn # aws managed role to give permission to private ecr repo i just made.
  task_role_arn = aws_iam_role.jacobs_ecs_role.arn
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_cloudwatch_event_rule" "twitch_ecs_schedule" {
  name = "scheduled_ecs_task_twitch" # change this name
  description = "Run everyday at 12am UTC"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task_twitch" {
  target_id = "jacobs_target_id_twitch"
  arn = aws_ecs_cluster.jacobs_ecs_cluster.arn
  rule = aws_cloudwatch_event_rule.twitch_ecs_schedule.name
  role_arn  = aws_iam_role.jacobs_ecs_ecr_role.arn

  ecs_target {
    launch_type = "FARGATE"
    network_configuration {
      subnets = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id] # do not use subnet group here - wont work.  need list of the individual subnet ids.
      security_groups = [aws_security_group.jacobs_task_security_group_tf.id]
      assign_public_ip = true
    }
    platform_version = "LATEST"
    task_count = 1
    task_definition_arn = aws_ecs_task_definition.jacobs_ecs_task_twitch.arn
  }
}

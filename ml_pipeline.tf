locals {
  ml_logs_name = "jacobs_ecs_logs_ml"
}

resource "aws_cloudwatch_log_group" "aws_ecs_logs_ml" {
  name              = local.ml_logs_name
  retention_in_days = 30

}

resource "aws_ecs_task_definition" "jacobs_ecs_task_ml" {
  family                   = "jacobs_task_ml"
  container_definitions    = <<TASK_DEFINITION
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
            "awslogs-group": "${local.ml_logs_name}",
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

# in march change to 11:30 am utc
# in nov change to 11:30 pm utc
# run everyday 30 minutes after main python script, 15 minutes after dbt
resource "aws_cloudwatch_event_rule" "etl_rule_ml" {
  name                = "python_scheduled_task_ml" # change this name
  description         = "Run every day at 11:30 am UTC"
  schedule_expression = "cron(30 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task_ml" {
  target_id = "jacobs_target_id"
  arn       = aws_ecs_cluster.jacobs_ecs_cluster.arn
  rule      = aws_cloudwatch_event_rule.etl_rule_ml.name
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
    task_definition_arn = aws_ecs_task_definition.jacobs_ecs_task_ml.arn
  }
}
resource "aws_cloudwatch_log_group" "aws_ecs_logs_ml" {
  name = "jacobs_ecs_logs_ml"
  retention_in_days = 30

}

resource "aws_ecs_task_definition" "jacobs_ecs_task_ml" {
  family                = "jacobs_task_ml"
  container_definitions = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:latest",
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
            "awslogs-group": "aws_ecs_logs_ml",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs-ml"
          }
        }
    } 
]
TASK_DEFINITION
  execution_role_arn = aws_iam_role.jacobs_ecs_role.arn # permissions needed for pulling ecr or writing to cloudwatch logs etc
  task_role_arn = aws_iam_role.jacobs_ecs_role.arn      # the actual permissions needed for when code runs (s3 access, ses access etc)
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

# run everyday 30 minutes after main python script, 15 minutes after dbt
resource "aws_cloudwatch_event_rule" "etl_rule_ml" {
  name = "python_scheduled_task_prod" # change this name
  description = "Run every day at 12:30 pm UTC"
  schedule_expression = "cron(30 12 * * ? *)"
}
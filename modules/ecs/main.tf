resource "aws_ecs_task_definition" "ecs_task_module" {
  family                   = var.ecs_id
  container_definitions    = var.ecs_container_definition
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  tags = {
    Name = var.ecs_id
  }
}

resource "aws_cloudwatch_log_group" "ecs_task_logs_module" {
  name              = var.ecs_logs_name
  retention_in_days = var.ecs_logs_retention
}

resource "aws_cloudwatch_event_rule" "ecs_task_rule_module" {
  count               = var.ecs_schedule ? 1 : 0
  name                = var.ecs_rule_name
  description         = var.ecs_rule_description
  schedule_expression = var.ecs_rule_cron
}

resource "aws_cloudwatch_event_target" "ecs_task_schedule_module" {
  count     = var.ecs_schedule ? 1 : 0
  target_id = var.ecs_target_id
  arn       = var.ecs_cluster_id
  rule      = aws_cloudwatch_event_rule.ecs_task_rule_module[0].name
  role_arn  = var.ecs_ecr_role

  ecs_target {
    launch_type = "FARGATE"
    network_configuration {
      subnets          = [var.ecs_subnet_1, var.ecs_subnet_2]
      security_groups  = [var.ecs_security_group_id]
      assign_public_ip = true
    }
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.ecs_task_module.arn
  }
}
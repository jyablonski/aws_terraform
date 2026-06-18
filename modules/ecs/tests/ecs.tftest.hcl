# Mocked ARN values are synthetic and are not validated against real AWS provider
# behavior.
mock_provider "aws" {
  mock_resource "aws_ecs_task_definition" {
    defaults = {
      arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/unit-task:1"
    }
  }

  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/ecs/unit"
    }
  }
}

variables {
  ecs_id                   = "unit-task"
  ecs_container_definition = "[{\"name\":\"unit\",\"image\":\"example:latest\",\"essential\":true}]"
  ecs_execution_role_arn   = "arn:aws:iam::123456789012:role/ecs-execution"
  ecs_task_role_arn        = "arn:aws:iam::123456789012:role/ecs-task"
  ecs_logs_name            = "/ecs/unit"
  ecs_rule_name            = "unit-rule"
  ecs_rule_description     = "Unit schedule"
  ecs_rule_cron            = "cron(0 * * * ? *)"
  ecs_ecr_role             = "arn:aws:iam::123456789012:role/events"
  ecs_target_id            = "unit-target"
  ecs_subnet_1             = "subnet-11111111"
  ecs_subnet_2             = "subnet-22222222"
  ecs_security_group_id    = "sg-11111111"
  ecs_cluster_id           = "arn:aws:ecs:us-east-1:123456789012:cluster/unit"
  ecs_schedule             = true
}

run "valid_inputs_configure_task_definition_and_logs" {
  command = plan

  assert {
    condition     = aws_ecs_task_definition.ecs_task_module.family == "unit-task"
    error_message = "Task definition family should come from ecs_id."
  }

  assert {
    condition     = aws_ecs_task_definition.ecs_task_module.cpu == "256"
    error_message = "Default task CPU should be 256."
  }

  assert {
    condition     = aws_cloudwatch_log_group.ecs_task_logs_module.retention_in_days == 7
    error_message = "Default log retention should be 7 days."
  }
}

run "schedule_enabled_creates_rule_and_target" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_event_rule.ecs_task_rule_module) == 1
    error_message = "ecs_schedule=true should create one EventBridge rule."
  }

  assert {
    condition = length(aws_cloudwatch_event_target.ecs_task_schedule_module[0].ecs_target[0].network_configuration[0].subnets) == 2 && contains(
      aws_cloudwatch_event_target.ecs_task_schedule_module[0].ecs_target[0].network_configuration[0].subnets,
      "subnet-11111111",
      ) && contains(
      aws_cloudwatch_event_target.ecs_task_schedule_module[0].ecs_target[0].network_configuration[0].subnets,
      "subnet-22222222",
    )
    error_message = "Scheduled ECS target should use both configured subnets."
  }
}

run "schedule_disabled_omits_rule_and_target" {
  command = plan

  variables {
    ecs_schedule = false
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.ecs_task_rule_module) == 0
    error_message = "ecs_schedule=false should omit the EventBridge rule."
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.ecs_task_schedule_module) == 0
    error_message = "ecs_schedule=false should omit the EventBridge target."
  }
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.ecs_task_module.arn
}

output "ecs_task_logs_arn" {
  value = aws_cloudwatch_log_group.ecs_task_logs_module.arn
}

variable "ecs_id" {
  type = string
}

variable "ecs_container_definition" {
  type        = any
  description = "Container definition overrides which allows for mapping environment variables."
  default     = {}
}

variable "ecs_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecs_cpu" {
  type    = number
  default = 256
}

variable "ecs_memory" {
  type    = number
  default = 512
}

variable "ecs_logs_name" {
  type = string
}

variable "ecs_logs_retention" {
  type    = number
  default = 7
}

variable "ecs_rule_name" {
  type = string
}

variable "ecs_rule_description" {
  type = string
}

variable "ecs_rule_cron" {
  type = string
}

variable "ecs_ecr_role" {
  type = string
}

variable "ecs_target_id" {
  type = string
}

variable "ecs_subnet_1" {
  type = string
}

variable "ecs_subnet_2" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_schedule" {
  type        = bool
  description = "Boolean which will additionally build Scheduling Resources if true, or only build the ECS Task Definition + Log Group if false"
}

variable "ecs_network_mode" {
  type    = string
  default = "awsvpc"
}

variable "ecs_compatability" {
  type    = string
  default = "FARGATE"
}
variable "alarm_name" {
  type = string
}

variable "alarm_description" {
  type = string
}

variable "alarm_comparison" {
  type = string
}

variable "alarm_threshold" {
  type    = number
  default = 75
}

variable "alarm_evaluation_periods" {
  type    = number
  default = 1
}

variable "alarm_metric_type" {
  type = string
}

variable "alarm_period" {
  type        = number
  description = "time (in seconds) to check metrics"
  default     = 300
}

variable "alarm_type" {
  type        = string
  description = "Either 'cloudwatch' or 'events' depending on what principal service is sending events to SNS."
  default     = "cloudwatch"
}

variable "target_endpoint" {
  type = string
}

variable "sns_protocol" {
  type    = string
  default = "https"
}

variable "db_id" {
  type = string
}

variable "is_metric_alarm" {
  type        = bool
  description = "boolean to see if this module is for a metric alarm, or for a cloudwatch event pattern"
  default     = true
}

variable "event_rule_pattern" {
  type = string
}
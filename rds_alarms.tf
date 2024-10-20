# module "rds_cpu_alarm" {
#   source             = "./modules/alarms"
#   alarm_type         = "cloudwatch"
#   is_metric_alarm    = true
#   event_rule_pattern = ""

#   alarm_name               = "rds-cpu-alarm"
#   alarm_description        = "Metric Alarm to check RDS CPU Utilization and send alarms to Pagerduty"
#   alarm_comparison         = "GreaterThanOrEqualToThreshold"
#   alarm_threshold          = 75
#   alarm_evaluation_periods = 2
#   alarm_metric_type        = "CPUUtilization"
#   alarm_period             = 300
#   db_id                    = aws_db_instance.jacobs_rds_tf.identifier

#   sns_protocol    = "https"
#   target_endpoint = var.pagerduty_endpoint

# }

# module "rds_read_latency_alarm" {
#   source             = "./modules/alarms"
#   alarm_type         = "cloudwatch"
#   is_metric_alarm    = true
#   event_rule_pattern = ""

#   alarm_name               = "rds-read-latency-check"
#   alarm_description        = "Metric Alarm to check RDS Read Latency and send alarms to Pagerduty"
#   alarm_comparison         = "GreaterThanOrEqualToThreshold"
#   alarm_threshold          = 0.05
#   alarm_evaluation_periods = 2
#   alarm_metric_type        = "ReadLatency"
#   alarm_period             = 300
#   db_id                    = aws_db_instance.jacobs_rds_tf.identifier

#   sns_protocol    = "https"
#   target_endpoint = var.pagerduty_endpoint

# }

# module "rds_write_latency_alarm" {
#   source             = "./modules/alarms"
#   alarm_type         = "cloudwatch"
#   is_metric_alarm    = true
#   event_rule_pattern = ""

#   alarm_name               = "rds-cpu-check"
#   alarm_description        = "Metric Alarm to check RDS Write Latency and send alarms to Pagerduty"
#   alarm_comparison         = "GreaterThanOrEqualToThreshold"
#   alarm_threshold          = 0.05
#   alarm_evaluation_periods = 2
#   alarm_metric_type        = "WriteLatency"
#   alarm_period             = 300
#   db_id                    = aws_db_instance.jacobs_rds_tf.identifier

#   sns_protocol    = "https"
#   target_endpoint = var.pagerduty_endpoint

# }
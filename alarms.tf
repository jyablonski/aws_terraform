module "rds_alarm" {
  source             = "./modules/alarms"
  alarm_type         = "cloudwatch"
  is_metric_alarm    = true
  event_rule_pattern = ""

  alarm_name               = "rds-cpu-check"
  alarm_description        = "Metric Alarm to check RDS CPU Utilization and send alarms to Pagerduty"
  alarm_comparison         = "GreaterThanOrEqualToThreshold"
  alarm_threshold          = 75
  alarm_evaluation_periods = 2
  alarm_metric_type        = "CPUUtilization"
  alarm_period             = 300
  db_id                    = aws_db_instance.jacobs_rds_tf.id

  sns_protocol    = "https"
  target_endpoint = var.pagerduty_endpoint

}

module "ecs_task_alarm" {
  source             = "./modules/alarms"
  alarm_type         = "events"
  is_metric_alarm    = false
  event_rule_pattern = <<EOF
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Task State Change"
  ],
  "detail": {
    "lastStatus": [
      "STOPPED"
    ],
    "containers": {
      "exitCode": [
        {
          "anything-but": 0
        }
      ]
    }
  }
}
EOF

  alarm_name               = "ecs-task-check"
  alarm_description        = "Eventbridge Rule to check for failed ECS Tasks and send alarms to Pagerduty"
  alarm_comparison         = ""
  alarm_threshold          = 1
  alarm_evaluation_periods = 1
  alarm_metric_type        = ""
  alarm_period             = 1
  db_id                    = aws_db_instance.jacobs_rds_tf.id

  sns_protocol    = "https"
  target_endpoint = var.ecs_pagerduty_endpoint

}
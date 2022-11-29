# RDS ALARMS
resource "aws_cloudwatch_metric_alarm" "database-storage-low-alarm" {
  count = var.is_metric_alarm ? 1 : 0

  alarm_name                = var.alarm_name
  alarm_description         = var.alarm_description
  alarm_actions             = [aws_sns_topic.this.arn]
  comparison_operator       = var.alarm_comparison
  threshold                 = var.alarm_threshold
  evaluation_periods        = var.alarm_evaluation_periods
  metric_name               = var.alarm_metric_type
  namespace                 = "AWS/RDS"
  period                    = var.alarm_period
  statistic                 = "Average"
  insufficient_data_actions = []
  actions_enabled           = true

  dimensions = {
    DBInstanceIdentifier = "${var.db_id}"
  }
}

resource "aws_iam_role" "this" {
  name        = "${var.alarm_name}-role"
  description = "Role for SNS Topic ${var.alarm_name} to write to Cloudwatch Logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_policy" "this" {
  name = "${var.alarm_name}-log-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:PutMetricFilter",
                "logs:PutRetentionPolicy"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_sns_topic" "this" {
  name                              = "${var.alarm_name}-topic"
  http_failure_feedback_role_arn    = aws_iam_role.this.arn
  http_success_feedback_role_arn    = aws_iam_role.this.arn
  http_success_feedback_sample_rate = 100

  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "this" {
  count = var.is_metric_alarm ? 0 : 1

  name        = "${var.alarm_name}-event"
  description = var.alarm_description

  event_pattern = var.event_rule_pattern
}

resource "aws_cloudwatch_event_target" "this" {
  count = var.is_metric_alarm ? 0 : 1

  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = "${var.alarm_name}-target-id"
  arn       = aws_sns_topic.this.arn
}

data "aws_iam_policy_document" "this" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["${var.alarm_type}.amazonaws.com"]
    }

    resources = [aws_sns_topic.this.arn]
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = var.sns_protocol
  endpoint  = var.target_endpoint
}

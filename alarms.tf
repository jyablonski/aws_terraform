locals {
  lambda_alarm_topic    = "jacobs-sns-alarms-topic"
  lambda_alarm_function = "jacobs_lambda_alarm_function"
}

resource "aws_sns_topic" "jacobs_sns_alarms_topic" {
  name = local.lambda_alarm_topic
}

resource "aws_cloudwatch_metric_alarm" "rds_alarm" {

  alarm_name          = "rds-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 86400
  statistic           = "Average"
  threshold           = 1
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.jacobs_sns_alarms_topic.arn]
  alarm_description   = "Triggered by Low CPU Utilization in RDS"
  treat_missing_data  = "notBreaching"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
    Terraform   = local.Terraform
  }
}

resource "aws_cloudwatch_log_group" "jacobs_lambda_alarm_logs" {
  name              = "/aws/lambda/${local.lambda_alarm_function}"
  retention_in_days = 7
}

data "archive_file" "lambda_alarm_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda_alarm/"
  output_path = "${path.module}/myzip/lambda_alarm5.zip"
}

# im cheating and using an old role for now
# https://api.klayers.cloud//api/v2/p3.9/layers/latest/us-east-1/html
resource "aws_lambda_function" "jacobs_lambda_alarm_function" {
  filename      = "${path.module}/myzip/lambda_alarm5.zip"
  function_name = local.lambda_alarm_function
  role          = aws_iam_role.jacobs_adhoc_sns_lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 3

  layers = [
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-requests:4",
  ]

  environment {
    variables = {
      WEBHOOK_URL = "${var.jacobs_discord_webhook}"
    }
  }

  tags = {
    Name        = local.env_name_adhoc
    Environment = local.env_type_adhoc
  }
}

resource "aws_sns_topic_subscription" "enable_lambda_alarm" {
  topic_arn = aws_sns_topic.jacobs_sns_alarms_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.jacobs_lambda_alarm_function.arn
}

resource "aws_lambda_permission" "allow_lambda_alarm_permission" {
  statement_id  = "AllowLambdaAlarm"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_lambda_alarm_function.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.jacobs_sns_alarms_topic.arn
}


# resource "aws_sns_topic_subscription" "lambda_alarm" {
#   topic_arn = aws_sns_topic.sns_alarms.arn
#   protocol  = "lambda"
#   endpoint  = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${local.name_dash}-alarms-discord"
# }
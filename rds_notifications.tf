resource "aws_cloudwatch_event_rule" "jacobs_rds_events_rule" {
  name        = "jacobs-rds-events-rule"
  description = "Capture RDS DB Instance Events"

  event_pattern = <<EOF
{
  "source": ["aws.rds"],
  "detail-type": ["RDS DB Instance Event"]
}
EOF
}

resource "aws_sns_topic" "jacobs_rds_sns_topic" {
  name = "jacobs-rds-sns-topic"
}

# subscribe the rds event to the sns topic im creating for it
resource "aws_cloudwatch_event_target" "jacobs_rds_sns_topic_target" {
  rule      = aws_cloudwatch_event_rule.jacobs_rds_events_rule.name
  target_id = "SendRDSEventsToSNS"
  arn       = aws_sns_topic.jacobs_rds_sns_topic.arn
}

data "aws_iam_policy_document" "jacobs_rds_sns_topic_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    # allow events.amazonaws.com to send events to this specified sns topic
    resources = [aws_sns_topic.jacobs_rds_sns_topic.arn]
  }
}

resource "aws_sns_topic_policy" "jacobs_rds_sns_topic_policy" {
  arn    = aws_sns_topic.jacobs_rds_sns_topic.arn
  policy = data.aws_iam_policy_document.jacobs_rds_sns_topic_policy_doc.json
}

# the direct way of doing it
# resource "aws_db_event_subscription" "jacobs_rds_sns_subscription" {
#   name      = "jacobs-rds-sns-subscription"
#   sns_topic = aws_sns_topic.jacobs_rds_sns_topic.arn

#   source_type = "db-instance"
#   source_ids  = [aws_db_instance.jacobs_rds_tf.id]

#   event_categories = [
#     "availability",
#     "deletion",
#     "failover",
#     "failure",
#     "low storage",
#     "maintenance",
#     "notification",
#     "read replica",
#     "recovery",
#     "restoration",
#   ]
# }

resource "aws_iam_role" "jacobs_rds_sns_lambda_role" {
  name = "jacobs_rds_sns_lambda_role"
  description = "Role created for AWS Lambda to process RDS Events"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_rds_sns_lambda_log_attachment1" {
  role       = aws_iam_role.jacobs_rds_sns_lambda_role.name
  policy_arn = "arn:aws:iam::324816727452:policy/service-role/AWSLambdaBasicExecutionRole-6777176a-f601-4ad8-864d-53578dfceb07"
}

resource "aws_iam_role_policy_attachment" "jacobs_rds_sns_lambda_log_attachment2" {
  role       = aws_iam_role.jacobs_rds_sns_lambda_role.name
  policy_arn = aws_iam_policy.jacobs_lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "jacobs_rds_sns_lambda_log_attachment_3" {
  role       = aws_iam_role.jacobs_rds_sns_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}


resource "aws_cloudwatch_log_group" "jacobs_rds_sns_lambda_logs" {
  name              = "/aws/lambda/jacobs_rds_sns_lambda_function"
  retention_in_days = 7
}

data "archive_file" "lambda_rds" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_rds_eventbridge/"
  output_path = "${path.module}/myzip/lambda_rds11.zip"
}

resource "aws_lambda_function" "jacobs_rds_sns_lambda_function" {
  filename                       = "${path.module}/myzip/lambda_rds11.zip"
  function_name                  = "jacobs_rds_sns_lambda_function"
  role                           = aws_iam_role.jacobs_rds_sns_lambda_role.arn
  handler                        = "main.lambda_handler"
  runtime                        = "python3.8"
  memory_size                    = 128
  timeout                        = 3
  depends_on                     = [aws_iam_role_policy_attachment.lambda_logs,
                                    aws_cloudwatch_log_group.jacobs_rds_sns_lambda_logs,
                                   ]
}

resource "aws_sns_topic_subscription" "allow_sns_invoke_rds_lambda" {
  topic_arn = aws_sns_topic.jacobs_rds_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.jacobs_rds_sns_lambda_function.arn
}

resource "aws_lambda_permission" "allow_rds_sns_lambda_permission" {
  statement_id  = "AllowRDSLambdaExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_rds_sns_lambda_function.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.jacobs_rds_sns_topic.arn
}


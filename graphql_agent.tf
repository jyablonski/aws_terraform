# code to create a lambda which processes graphql invocations and stores them to sql
# graphql -> sns -> sqs -> lambda -> sql
# you use sqs in the middle bc i dont want to immediately process each message, lambda should trigger on a 1 hr cadence.

locals {
  env_name_graphql    = "Jacobs GraphQL Agent"
  env_type_graphql    = "Test" # cant have an apostrophe in the tag name
  graphql_sqs_name    = "jacobs-graphql-agent-sqs"
  graphql_sns_name    = "jacobs-graphql-agent-topic"
  graphql_logs_name   = "jacobs-grapql-agent-logs"
  graphql_lambda_name = "jacobs_graphql_agent_lambda"
}

resource "aws_sns_topic" "jacobs_graphql_sns_topic" {
  name       = local.graphql_sns_name
  fifo_topic = false

  tags = {
    Name        = local.env_name_graphql
    Environment = local.env_type_graphql
  }
}


resource "aws_sqs_queue" "jacobs_graphql_sqs_queue" {
  name                       = local.graphql_sqs_name
  delay_seconds              = 0
  message_retention_seconds  = 14400 # 4 hrs boi
  max_message_size           = 262144
  visibility_timeout_seconds = 120

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
                "Service": "sns.amazonaws.com"
            },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:jacobs-graphql-agent-sqs",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_sns_topic.jacobs_graphql_sns_topic.arn}" }
      }
    }
  ]
}
POLICY

  tags = {
    Name        = local.env_name_graphql
    Environment = local.env_type_graphql
  }
}

resource "aws_cloudwatch_log_group" "jacobs_graphql_lambda_logs" {
  name              = "/aws/lambda/${local.graphql_lambda_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "jacobs_graphql_lambda_role" {
  name        = "jacobs_graphql_lambda_role"
  description = "Role created for AWS Lambda which processes messages in an SQS Queue"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# resource "aws_iam_policy" "jacobs_graphql_lambda_trigger_policy" {
#   name        = "graphql_lambda_trigger_policy"
#   description = "IAM policy to trigger a Lambda from EventBridge Rule"

#   policy = <<EOF
# {
#   "Effect": "Allow",
#   "Action": "lambda:InvokeFunction",
#   "Resource": "arn:aws:lambda:${var.region}:${local.account_id}:function:${aws_lambda_function.jacobs_graphql_agent_lambda_function.id}",
#   "Principal": {
#     "Service": "events.amazonaws.com"
#   },
#   "Condition": {
#     "ArnLike": {
#       "AWS:SourceArn": "arn:aws:events:${var.region}:${local.account_id}:rule/${aws_cloudwatch_event_rule.jacobs_graphql_agent_rule.id}"
#     }
#   },
#   "Sid": "InvokeLambdaFunction"
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "jacobs_graphql_rule_policy" {
#   role       = aws_iam_role.jacobs_graphql_lambda_role.name
#   policy_arn = aws_iam_policy.jacobs_graphql_lambda_trigger_policy.arn
# }

resource "aws_iam_role_policy_attachment" "jacobs_graphql_eventbridge_rule_policy" {
  role       = aws_iam_role.jacobs_graphql_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_graphql_logs_policy" {
  role       = aws_iam_role.jacobs_graphql_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_graphql_sqs_policy" {
  role       = aws_iam_role.jacobs_graphql_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

data "archive_file" "lambda_graphql_agent_sqs" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda_graphql_agent/"
  output_path = "${path.module}/myzip/lambda_graphql_agent2.zip"
}

# https://github.com/keithrozario/Klayers
resource "aws_lambda_function" "jacobs_graphql_agent_lambda_function" {
  filename      = "${path.module}/myzip/lambda_graphql_agent2.zip"
  function_name = local.graphql_lambda_name
  role          = aws_iam_role.jacobs_graphql_lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  memory_size   = 256

  layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p38-pandas:3",
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p38-SQLAlchemy:2",
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-aws-psycopg2:1"
  ]

  environment {
    variables = {
      RDS_USER = "${var.jacobs_rds_user}",
      RDS_PW   = "${var.jacobs_rds_pw}",
      IP       = "${aws_db_instance.jacobs_rds_tf.address}",
      RDS_DB   = "jacob_db",
      SQS_URL  = "${aws_sqs_queue.jacobs_graphql_sqs_queue.url}"
    }
  }
}

resource "aws_sns_topic_subscription" "jacobs_graphql_topic_subscription" {
  topic_arn = aws_sns_topic.jacobs_graphql_sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.jacobs_graphql_sqs_queue.arn
}

resource "aws_cloudwatch_event_rule" "jacobs_graphql_agent_rule" {
  name                = "jacobs_graphql_agent_trigger"
  description         = "GraphQL Agent which processes SQS Messages every 1 hr"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_lambda_permission" "jacobs_graphql_cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatchGraphQL"
  action        = "lambda:InvokeFunction"
  function_name = local.graphql_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.jacobs_graphql_agent_rule.arn
}

resource "aws_cloudwatch_event_target" "jacobs_graphql_agent_target" {
  target_id = "jacobs_graphql_agent_id"
  arn       = aws_lambda_function.jacobs_graphql_agent_lambda_function.arn
  rule      = aws_cloudwatch_event_rule.jacobs_graphql_agent_rule.name

}
# code to create a lambda which processes graphql invocations and stores them to sql
# graphql -> sns -> sqs -> lambda -> sql
# you use sqs in the middle bc i dont want to immediately process each message, lambda should trigger on a 1 hr cadence.

locals {
  env_name_graphql    = "Jacobs GraphQL Agent"
  env_type_graphql    = "Test" # cant have an apostrophe in the tag name
  graphql_sqs_name    = "jacobs-graphql-agent-sqs"
  graphql_sns_name    = "jacobs-graphql-agent-topic"
  graphql_lambda_name = "jacobs_graphql_agent_lambda"
}

# resource "aws_sns_topic" "jacobs_graphql_sns_topic" {
#   name       = local.graphql_sns_name
#   fifo_topic = false

#   tags = {
#     Name        = local.env_name_graphql
#     Environment = local.env_type_graphql
#   }
# }

# resource "aws_iam_user" "jacobs_deta_user" {
#   name = "jacobs_deta_user"

#   tags = {
#     Name        = local.env_name_graphql
#     Environment = local.env_type_graphql
#   }
# }

# resource "aws_iam_user_policy" "jacobs_deta_user_policy" {
#   name = "jacobs-deta-user-policy"
#   user = aws_iam_user.jacobs_deta_user.name

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "sns:Publish"
#       ],
#       "Effect": "Allow",
#       "Resource": "${aws_sns_topic.jacobs_graphql_sns_topic.arn}"
#     }
#   ]
# }
# EOF
# }

# resource "aws_sqs_queue" "jacobs_graphql_sqs_queue" {
#   name                       = local.graphql_sqs_name
#   delay_seconds              = 0
#   message_retention_seconds  = 86400 # 24 hrs boi
#   max_message_size           = 262144
#   visibility_timeout_seconds = 120

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#                 "Service": "sns.amazonaws.com"
#             },
#       "Action": "sqs:SendMessage",
#       "Resource": "arn:aws:sqs:*:*:jacobs-graphql-agent-sqs",
#       "Condition": {
#         "ArnEquals": { "aws:SourceArn": "${aws_sns_topic.jacobs_graphql_sns_topic.arn}" }
#       }
#     }
#   ]
# }
# POLICY

#   tags = {
#     Name        = local.env_name_graphql
#     Environment = local.env_type_graphql
#   }
# }

# resource "aws_cloudwatch_log_group" "jacobs_graphql_lambda_logs" {
#   name              = "/aws/lambda/${local.graphql_lambda_name}"
#   retention_in_days = 7
# }

# resource "aws_iam_role" "jacobs_graphql_lambda_role" {
#   name        = "jacobs_graphql_lambda_role"
#   description = "Role created for AWS Lambda which processes messages in an SQS Queue"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "jacobs_graphql_eventbridge_rule_policy" {
#   role       = aws_iam_role.jacobs_graphql_lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "jacobs_graphql_logs_policy" {
#   role       = aws_iam_role.jacobs_graphql_lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "jacobs_graphql_sqs_policy" {
#   role       = aws_iam_role.jacobs_graphql_lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
# }

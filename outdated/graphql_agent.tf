# data "archive_file" "lambda_graphql_agent_sqs" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambdas/lambda_graphql_agent/"
#   output_path = "${path.module}/myzip/lambda_graphql_agent.zip"
# }

# # https://github.com/keithrozario/Klayers
# resource "aws_lambda_function" "jacobs_graphql_agent_lambda_function" {
#   filename      = "${path.module}/myzip/lambda_graphql_agent.zip"
#   function_name = local.graphql_lambda_name
#   role          = aws_iam_role.jacobs_graphql_lambda_role.arn
#   handler       = "main.lambda_handler"
#   runtime       = "python3.8"
#   memory_size   = 256

#   source_code_hash = "${data.archive_file.lambda_graphql_agent_sqs.output_base64sha256}"

#   layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p38-pandas:3",
#     "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p38-SQLAlchemy:2",
#     "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-aws-psycopg2:1"
#   ]

#   environment {
#     variables = {
#       RDS_USER = "${var.jacobs_rds_user}",
#       RDS_PW   = "${var.jacobs_rds_pw}",
#       IP       = "${aws_db_instance.jacobs_rds_tf.address}",
#       RDS_DB   = "jacob_db",
#       SQS_URL  = "${aws_sqs_queue.jacobs_graphql_sqs_queue.url}"
#     }
#   }
# }

# resource "aws_sns_topic_subscription" "jacobs_graphql_topic_subscription" {
#   topic_arn = aws_sns_topic.jacobs_graphql_sns_topic.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.jacobs_graphql_sqs_queue.arn
# }

# resource "aws_cloudwatch_event_rule" "jacobs_graphql_agent_rule" {
#   name                = "jacobs_graphql_agent_trigger"
#   description         = "GraphQL Agent which processes SQS Messages every 12 hrs"
#   schedule_expression = "cron(0 0/12 * * ? *)"
# }

# resource "aws_lambda_permission" "jacobs_graphql_cloudwatch_permission" {
#   statement_id  = "AllowExecutionFromCloudWatchGraphQL"
#   action        = "lambda:InvokeFunction"
#   function_name = local.graphql_lambda_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.jacobs_graphql_agent_rule.arn
# }

# resource "aws_cloudwatch_event_target" "jacobs_graphql_agent_target" {
#   target_id = "jacobs_graphql_agent_id"
#   arn       = aws_lambda_function.jacobs_graphql_agent_lambda_function.arn
#   rule      = aws_cloudwatch_event_rule.jacobs_graphql_agent_rule.name

# }


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
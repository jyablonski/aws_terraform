# can use this to send a manual, ad hoc message to an sns topic to trigger a lambda to do ,,, something
# for now the lambda just sends an email that an event occurred

# sns = boto3.client('sns')
# topic_arn = 'arn:aws:sns:us-east-1:xxx:jacobs-adhoc-sns-topic'
# sns.publish(TopicArn=topic_arn, 
#             Message="Hello World!")

locals {
  env_name_adhoc    = "Jacobs Practice ad hoc Lambda Trigger"
  env_type_adhoc    = "Test" # cant have an apostrophe in the tag name
  adhoc_sns_name    = "jacobs-adhoc-sns-topic"
  adhoc_logs_name   = "jacobs-adhoc-logs"
  adhoc_lambda_name = "jacobs_adhoc_lambda_function"
}

resource "aws_sns_topic" "jacobs_adhoc_sns_topic" {
  name       = local.adhoc_sns_name
  fifo_topic = false

  tags = {
    Name        = local.env_name_adhoc
    Environment = local.env_type_adhoc
  }
}

resource "aws_iam_role" "jacobs_adhoc_sns_lambda_role" {
  name               = "jacobs_adhoc_sns_lambda_role"
  description        = "Role created for AWS Lambda to Run ad hoc jobs after sns message"
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

resource "aws_iam_role_policy_attachment" "jacobs_adhoc_sns_lambda_log_attachment1" {
  role       = aws_iam_role.jacobs_adhoc_sns_lambda_role.name
  policy_arn = "arn:aws:iam::324816727452:policy/service-role/AWSLambdaBasicExecutionRole-6777176a-f601-4ad8-864d-53578dfceb07"
}

resource "aws_iam_role_policy_attachment" "jacobs_adhoc_sns_lambda_log_attachment2" {
  role       = aws_iam_role.jacobs_adhoc_sns_lambda_role.name
  policy_arn = aws_iam_policy.jacobs_lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "jacobs_adhoc_sns_lambda_log_attachment_3" {
  role       = aws_iam_role.jacobs_adhoc_sns_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}


resource "aws_cloudwatch_log_group" "jacobs_adhoc_sns_lambda_logs" {
  name              = "/aws/lambda/${local.adhoc_lambda_name}"
  retention_in_days = 7
}

data "archive_file" "lambda_adhoc_sns_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda_adhoc_sns/"
  output_path = "${path.module}/myzip/lambda_adhoc_sns4.zip"
}

resource "aws_lambda_function" "jacobs_adhoc_sns_lambda_function" {
  filename      = "${path.module}/myzip/lambda_adhoc_sns4.zip"
  function_name = local.adhoc_lambda_name
  role          = aws_iam_role.jacobs_adhoc_sns_lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 3

  tags = {
    Name        = local.env_name_adhoc
    Environment = local.env_type_adhoc
  }
}

resource "aws_sns_topic_subscription" "enable_adhoc_lambda_sns" {
  topic_arn = aws_sns_topic.jacobs_adhoc_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.jacobs_adhoc_sns_lambda_function.arn
}

resource "aws_lambda_permission" "allow_adhoc_sns_lambda_permission" {
  statement_id  = "AllowadhocLambdaExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_adhoc_sns_lambda_function.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.jacobs_adhoc_sns_topic.arn
}
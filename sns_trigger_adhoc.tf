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

# this policy allows the ad hoc lambda to run the scheduled ECS task definitions in the main cluster
resource "aws_iam_policy" "lambda_sns_ecs_policy" {
  name        = "lambda-sns-ecs_policy"
  description = "Least-privilege policy for the ad hoc lambda to trigger ECS task definitions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RunApprovedEcsTasks"
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
        ]
        Condition = {
          ArnEquals = {
            "ecs:cluster" = aws_ecs_cluster.jacobs_ecs_cluster.arn
          }
        }
        Resource = [
          module.webscrape_ecs_module.ecs_task_definition_arn,
          module.dbt_ecs_module.ecs_task_definition_arn,
          module.ml_ecs_module.ecs_task_definition_arn,
          module.fake_ecs_module.ecs_task_definition_arn,
          module.airflow_ecs_module.ecs_task_definition_arn,
          module.dash_ecs_module.ecs_task_definition_arn,
        ]
      },
      {
        Sid    = "PassEcsTaskRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [
          aws_iam_role.jacobs_ecs_role.arn,
        ]
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jacobs_adhoc_sns_lambda_log_attachment1" {
  role       = aws_iam_role.jacobs_adhoc_sns_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "jacobs_adhoc_sns_lambda_log_attachment_5" {
  role       = aws_iam_role.jacobs_adhoc_sns_lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_ecs_policy.arn
}


resource "aws_cloudwatch_log_group" "jacobs_adhoc_sns_lambda_logs" {
  name              = "/aws/lambda/${local.adhoc_lambda_name}"
  retention_in_days = 7
}


# New format to trigger ECS tasks from Lambda
resource "aws_cloudwatch_log_group" "jacobs_adhoc_sns_ecs_lambda_logs" {
  name              = "/aws/lambda/jacobs_adhoc_sns_ecs_lambda_function"
  retention_in_days = 7
}

data "archive_file" "lambda_adhoc_sns_fake_ecs_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda_adhoc_sns_ecs/"
  output_path = "${path.module}/myzip/lambda_adhoc_sns_ecs.zip"
}

resource "aws_lambda_function" "jacobs_adhoc_sns_ecs_lambda_function" {
  filename      = "${path.module}/myzip/lambda_adhoc_sns_ecs.zip"
  function_name = "jacobs_adhoc_sns_ecs_lambda_function"
  role          = aws_iam_role.jacobs_adhoc_sns_lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 3

  source_code_hash = data.archive_file.lambda_adhoc_sns_fake_ecs_zip.output_base64sha256

  environment {
    variables = {
      ECS_CLUSTER_NAME      = aws_ecs_cluster.jacobs_ecs_cluster.name
      ECS_SECURITY_GROUP_ID = aws_security_group.jacobs_task_security_group_tf.id
      ECS_SUBNET_IDS        = join(",", [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id])
    }
  }

  tags = {
    Name        = local.env_name_adhoc
    Environment = local.env_type_adhoc
  }

  lifecycle {
    ignore_changes = [source_code_hash]
  }
}

resource "aws_sns_topic_subscription" "enable_adhoc_lambda_sns_ecs" {
  topic_arn = aws_sns_topic.jacobs_adhoc_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.jacobs_adhoc_sns_ecs_lambda_function.arn
}

resource "aws_lambda_permission" "allow_adhoc_sns_ecs_lambda_permission" {
  statement_id  = "AllowadhocLambdaExecutionFromSNSecs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_adhoc_sns_ecs_lambda_function.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.jacobs_adhoc_sns_topic.arn
}

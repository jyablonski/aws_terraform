locals {
  shiny_service_name = "shiny_dashboard_prod"
}

# resource "aws_ecs_service" "shiny_dashboard" {
#   name                               = local.shiny_service_name
#   cluster                            = aws_ecs_cluster.ecs_ec2_cluster.id
#   task_definition                    = module.shiny_ecs_module.ecs_task_definition_arn
#   desired_count                      = 1
#   deployment_minimum_healthy_percent = 1
#   deployment_maximum_percent         = 100
#   launch_type                        = "EC2"

# }

module "nba_dashboard_repo" {
  source              = "./modules/iam_github"
  iam_role_name       = "nba-dashboard"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/NBA-Dashboard"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.jacobs_repo.name}"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role" "shiny_restart_role" {
  name               = "${local.shiny_service_name}_lambda_role"
  description        = "Role created for Lambda to restart Shiny Dashboard"
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

resource "aws_iam_policy" "shiny_role_policy" {
  name        = "${local.shiny_service_name}_lambda_policy"
  description = "Policy for Lambda to restart Shiny everyday"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid":"AllowECSListStopTasks",
        "Effect":"Allow",
        "Action":
          [
            "ecs:ListTasks",
            "ecs:StopTask"
          ],
        "Resource":"*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "shiny_restart_role_policy_attachment" {
  role       = aws_iam_role.shiny_restart_role.name
  policy_arn = aws_iam_policy.shiny_role_policy.arn
}

data "archive_file" "lambda_shiny_restart_archive" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda_shiny_restart/"
  output_path = "${path.module}/myzip/lambda_shiny_restart.zip"
}

# https://github.com/keithrozario/Klayers
resource "aws_lambda_function" "shiny_restart_lambda" {
  filename      = "${path.module}/myzip/lambda_shiny_restart.zip"
  function_name = "${local.shiny_service_name}_lambda"
  role          = aws_iam_role.shiny_restart_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  memory_size   = 128

  source_code_hash = data.archive_file.lambda_shiny_restart_archive.output_base64sha256

  layers = [
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p311-requests-html:13"
  ]

  environment {
    variables = {
      WEBHOOK_URL     = "${var.slack_webhook_url}",
      ECS_EC2_CLUSTER = "${aws_ecs_cluster.ecs_ec2_cluster.arn}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "shiny_restart_rule" {
  name                = "${local.shiny_service_name}-rule"
  description         = "Trigger Shiny Restart everyday at 12:40 UTC"
  schedule_expression = "cron(40 12 * * ? *)"
}

resource "aws_lambda_permission" "shiny_restart_lambda_permission" {
  statement_id  = "AllowShinyRestartExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shiny_restart_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shiny_restart_rule.arn
}

# resource "aws_cloudwatch_event_target" "shiny_restart_target" {
#   target_id = "shiny_restart_event_id"
#   arn       = aws_lambda_function.shiny_restart_lambda.arn
#   rule      = aws_cloudwatch_event_rule.shiny_restart_rule.name

# }
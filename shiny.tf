locals {
  shiny_service_name = "shiny_dashboard_prod"
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

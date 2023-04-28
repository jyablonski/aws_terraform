resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = var.lambda_log_retention
}

resource "aws_iam_role" "this" {
  name        = "${var.lambda_name}_role"
  description = "Role created for ${var.lambda_name}"
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

resource "aws_iam_policy" "this" {
  name        = "${var.lambda_name}_policy"
  description = "IAM policy for ${var.lambda_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "lambda:InvokeFunction",
        "Resource": "arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.this.id}",
        "Condition": {
            "ArnLike": {
            "AWS:SourceArn": "arn:aws:events:${var.region}:${var.account_id}:rule/${aws_cloudwatch_event_rule.this[0].name}"
            }
        },
        "Sid": "InvokeLambdaFunction"
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.root}/lambdas/${var.lambda_name}/"
  output_path = "${path.root}/myzip/${var.lambda_name}.zip"
}

resource "aws_lambda_function" "this" {
  filename      = "${path.root}/myzip/${var.lambda_name}.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.this.arn
  handler       = "main.lambda_handler"
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout

  source_code_hash = data.archive_file.this.output_base64sha256

  layers = var.lambda_layers

  environment {
    variables = var.lambda_env_vars
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  count               = var.is_lambda_schedule ? 1 : 0
  name                = "${var.lambda_name}_rule"
  description         = "Rule to trigger ${var.lambda_name}"
  schedule_expression = var.lambda_cron #"cron(0 0/12 * * ? *)"
}

resource "aws_lambda_permission" "this" {
  count         = var.is_lambda_schedule ? 1 : 0
  statement_id  = "${var.lambda_name}_statement"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[0].arn
  #   qualifier     = aws_lambda_function.this.function_name
}

resource "aws_cloudwatch_event_target" "this" {
  count     = var.is_lambda_schedule ? 1 : 0
  target_id = "${var.lambda_name}_target"
  arn       = aws_lambda_function.this.arn
  rule      = aws_cloudwatch_event_rule.this[0].name
}

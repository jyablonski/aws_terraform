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
  count = var.create_lambda_role_policy ? 1 : 0

  name        = "${var.lambda_name}_policy"
  description = "IAM policy for ${var.lambda_name}"

  policy = var.lambda_role_policy
}

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create_lambda_role_policy ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "${path.root}/myzip/${var.lambda_name}.zip"
}

resource "aws_lambda_function" "this" {
  filename      = "${path.root}/myzip/${var.lambda_name}.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.this.arn
  handler       = var.lambda_handler
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
  schedule_expression = var.lambda_cron
}

resource "aws_lambda_permission" "this" {
  count         = var.is_lambda_schedule ? 1 : 0
  statement_id  = "${var.lambda_name}_statement"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[0].arn
}

resource "aws_cloudwatch_event_target" "this" {
  count     = var.is_lambda_schedule ? 1 : 0
  target_id = "${var.lambda_name}_target"
  arn       = aws_lambda_function.this.arn
  rule      = aws_cloudwatch_event_rule.this[0].name
}

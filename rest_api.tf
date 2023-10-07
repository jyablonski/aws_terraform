locals {
  rest_api_lambda_name = "jacobs_rest_api_lambda"
  rest_api_role_name   = "jacobs_rest_api_lambda_role"

}

resource "aws_iam_role" "jacobs_rest_api_lambda_role" {
  name               = local.rest_api_role_name
  description        = "Role created for AWS Lambda to process RDS Events"
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

resource "aws_iam_role_policy_attachment" "jacobs_rest_api_lambda_role_attachment1" {
  role       = aws_iam_role.jacobs_rest_api_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

# arn:aws:iam::aws:policy/AWSLambdaExecute
resource "aws_cloudwatch_log_group" "jacobs_rest_api_lambda_logs" {
  name              = "/aws/lambda/${local.rest_api_lambda_name}"
  retention_in_days = 7
}

resource "aws_lambda_function" "jacobs_rest_api_lambda_function" {
  architectures = ["x86_64"]
  function_name = local.rest_api_lambda_name
  role          = aws_iam_role.jacobs_rest_api_lambda_role.arn
  handler       = "src.server.handler"
  runtime       = "python3.11"
  memory_size   = 128
  timeout       = 20

  # define s3 bucket + the key in that backup with the zip
  # zip has BOTH the depencenies from requirements.txt and the application code itself.
  s3_bucket = aws_s3_bucket.jacobs_bucket_tf_dev.id
  s3_key    = "rest-api/lambda_function.zip"

  environment {
    variables = {
      RDS_USER                    = "${var.jacobs_rds_user}",
      RDS_PW                      = "${var.jacobs_rds_pw}",
      RDS_SCHEMA                  = "nba_prod"
      IP                          = "${aws_db_instance.jacobs_rds_tf.address}",
      RDS_DB                      = "${var.jacobs_rds_db}"
      OTEL_EXPORTER_OTLP_ENDPOINT = "${var.honeycomb_endpoint}"
      OTEL_EXPORTER_OTLP_HEADERS  = "${var.honeycomb_headers}"
      OTEL_SERVICE_NAME           = "${var.honeycomb_app_name}"
      API_KEY                     = "${var.rest_api_api_key}"
      ENV_TYPE                    = "prod"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.jacobs_rest_api_lambda_role_attachment1,
    aws_cloudwatch_log_group.jacobs_rest_api_lambda_logs,
  ]
}

resource "aws_lambda_function_url" "jacobs_rest_api_lambda_function_url" {
  function_name      = aws_lambda_function.jacobs_rest_api_lambda_function.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST"]
    max_age           = 43200 # 12 hrs
  }
}
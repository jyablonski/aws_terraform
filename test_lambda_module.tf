# module "lambda_test_module_2" {
#   source               = "./modules/lambda"
#   lambda_name          = "jyablonski-test-lambda2"
#   is_lambda_schedule   = false
#   lambda_log_retention = 7
#   lambda_cron          = "cron(15 11 1 4 ? *)"
#   lambda_runtime       = "python3.9"
#   lambda_memory        = 128
#   lambda_layers = [
#     "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-pandas:8",
#     "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-requests:8"
#   ]
#   lambda_env_vars = {
#     env1 = "hello1",
#     env2 = "hello2"
#   }
#   account_id = data.aws_caller_identity.current.account_id
#   region     = "us-east-1"
# }

module "lambda_cloudwatch_module" {
  source               = "./modules/lambda"
  lambda_name          = "lambda_cloudwatch_scraper"
  is_lambda_schedule   = true
  lambda_log_retention = 7
  lambda_cron          = "cron(30 12 * * ? *)"
  lambda_runtime       = "python3.9"
  lambda_memory        = 128
  lambda_layers = [
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-pandas:8",
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-requests:8",
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-psycopg2-binary:1",
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-SQLAlchemy:11"

  ]
  lambda_env_vars = {
    webhook_url = "${var.slack_webhook_url}",
    RDS_USER    = "${var.jacobs_rds_user}",
    RDS_PW      = "${var.jacobs_rds_pw}",
    RDS_HOST    = aws_db_instance.jacobs_rds_tf.address,
    RDS_DB      = "${var.jacobs_rds_db}",
  }
  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"
}

resource "aws_iam_policy" "cloudwatch_scraper_permissions" {
  name        = "lambda_cloudwatch_policy"
  description = "IAM policy for lambda_cloudwatch_scraper"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "cloudwatch:GetMetricData",
        "Resource": "*",
        "Sid": "GetMetricDataPermissions"
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_scraper_permissions" {
  role       = module.lambda_cloudwatch_module.lambda_iam_role_name
  policy_arn = aws_iam_policy.cloudwatch_scraper_permissions.arn
}
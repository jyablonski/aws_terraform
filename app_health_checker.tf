# https://github.com/keithrozario/Klayers
module "lambda_app_health_checker" {
  source               = "./modules/lambda"
  lambda_name          = "lambda_app_health_checker"
  is_lambda_schedule   = true
  lambda_log_retention = 7
  lambda_cron          = "cron(0 * * * ? *)"
  # cron runs every 1 hr indefinitely
  lambda_runtime = "python3.11"
  lambda_memory  = 128
  lambda_layers = [
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p311-requests:6"
  ]
  lambda_env_vars = {
    WEBHOOK_URL = "${var.slack_webhook_url}",
  }
  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"
}

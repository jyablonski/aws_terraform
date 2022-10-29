module "lambda_test_module_2" {
  source               = "./modules/lambda"
  lambda_name          = "jyablonski-test-lambda2"
  is_lambda_schedule   = true
  lambda_log_retention = 7
  lambda_cron          = "cron(15 11 1 4 ? *)"
  lambda_runtime       = "python3.9"
  lambda_memory        = 128
  lambda_layers = [
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-pandas:8",
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-requests:8"
  ]
  lambda_env_vars = {
    env1 = "hello1",
    env2 = "hello2"
  }
  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"
}

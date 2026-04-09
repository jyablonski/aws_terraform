locals {
  env_name_dynamodb    = "Jacobs Practice API"
  env_type_dynamodb    = "Test" # cant have an apostrophe in the tag name
  lambda_name_dynamodb = "jacobs_lambda_dynamodb"
  account_id           = data.aws_caller_identity.current.account_id
  jacobs_ip            = "104.153.228.249/32"
}

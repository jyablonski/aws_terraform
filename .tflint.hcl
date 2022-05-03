plugin "aws" {
    enabled = true
    version = "0.13.3"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_cloudwatch_log_group_invalid_name" {
  enabled = false
}

rule "aws_lambda_function_invalid_function_name" {
  enabled = false
}
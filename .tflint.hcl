plugin "aws" {
  enabled = true
  version = "0.34.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_cloudwatch_log_group_invalid_name" {
  enabled = false
}

rule "aws_lambda_function_invalid_function_name" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_unused_declarations" {
  enabled = false
}

rule "terraform_deprecated_interpolation" {
  enabled = false
}
# Mocked ARN values are synthetic and are not validated against real AWS provider
# behavior.
mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/unit_lambda_v2_role"
    }
  }

  mock_resource "aws_lambda_function" {
    defaults = {
      arn = "arn:aws:lambda:us-east-1:123456789012:function:unit_lambda_v2"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/unit_lambda_v2_policy"
    }
  }
}

mock_provider "archive" {}

variables {
  lambda_name       = "unit_lambda_v2"
  lambda_layers     = []
  lambda_env_vars   = { ENV = "test" }
  lambda_source_dir = "tests/fixtures/lambda_src"
}

run "defaults_create_lambda_without_schedule_or_custom_policy" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 0
    error_message = "Default is_lambda_schedule=false should not create an EventBridge rule."
  }

  assert {
    condition     = length(aws_iam_policy.this) == 0
    error_message = "Default create_lambda_role_policy=false should not create a custom policy."
  }

  assert {
    condition     = aws_lambda_function.this.handler == "main.lambda_handler"
    error_message = "Default Lambda handler should be main.lambda_handler."
  }
}

run "schedule_enabled_creates_event_resources" {
  command = plan

  variables {
    is_lambda_schedule = true
    lambda_cron        = "cron(15 * * * ? *)"
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 1
    error_message = "is_lambda_schedule=true should create an EventBridge rule."
  }

  assert {
    condition     = aws_cloudwatch_event_rule.this[0].schedule_expression == "cron(15 * * * ? *)"
    error_message = "Scheduled rule should use lambda_cron."
  }
}

run "custom_policy_toggle_creates_policy_and_attachment" {
  command = plan

  variables {
    create_lambda_role_policy = true
    lambda_role_policy        = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }

  assert {
    condition     = length(aws_iam_policy.this) == 1
    error_message = "create_lambda_role_policy=true should create a custom IAM policy."
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.this) == 1
    error_message = "create_lambda_role_policy=true should attach the custom IAM policy."
  }
}

# The disabled-schedule case is intentionally not asserted here: aws_iam_policy.this
# references aws_cloudwatch_event_rule.this[0] even when is_lambda_schedule=false,
# so the module is not plannable with scheduling disabled.
# Mocked ARN values are synthetic and are not validated against real AWS provider
# behavior.

mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/unit_lambda_role"
    }
  }

  mock_resource "aws_lambda_function" {
    defaults = {
      arn = "arn:aws:lambda:us-east-1:123456789012:function:unit_lambda"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/unit_lambda_policy"
    }
  }
}

mock_provider "archive" {}

variables {
  lambda_name        = "unit_lambda"
  lambda_layers      = ["arn:aws:lambda:us-east-1:123456789012:layer:unit:1"]
  lambda_env_vars    = { ENV = "test" }
  is_lambda_schedule = true
  account_id         = "123456789012"
}

run "valid_inputs_configure_lambda_and_role" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.name == "/aws/lambda/unit_lambda"
    error_message = "Log group name should be derived from lambda_name."
  }

  assert {
    condition     = aws_iam_role.this.name == "unit_lambda_role"
    error_message = "IAM role name should be derived from lambda_name."
  }

  assert {
    condition     = aws_lambda_function.this.function_name == "unit_lambda"
    error_message = "Lambda function name should come from lambda_name."
  }
}

run "defaults_configure_runtime_memory_timeout_and_cron" {
  command = plan

  assert {
    condition     = aws_lambda_function.this.runtime == "python3.9"
    error_message = "Default Lambda runtime should be python3.9."
  }

  assert {
    condition     = aws_lambda_function.this.memory_size == 128
    error_message = "Default Lambda memory should be 128 MB."
  }

  assert {
    condition     = aws_lambda_function.this.timeout == 60
    error_message = "Default Lambda timeout should be 60 seconds."
  }

  assert {
    condition     = aws_cloudwatch_event_rule.this[0].schedule_expression == "cron(0 * * * ? *)"
    error_message = "Default Lambda schedule should be hourly."
  }
}

run "schedule_enabled_creates_event_resources" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 1
    error_message = "is_lambda_schedule=true should create an EventBridge rule."
  }

  assert {
    condition     = aws_lambda_permission.this[0].statement_id == "unit_lambda_statement"
    error_message = "Lambda permission statement id should be derived from lambda_name."
  }

  assert {
    condition     = aws_cloudwatch_event_target.this[0].target_id == "unit_lambda_target"
    error_message = "Event target id should be derived from lambda_name."
  }
}

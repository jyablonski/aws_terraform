# Mocked ARN and policy document values are synthetic and are not validated
# against real AWS provider behavior. aws_iam_policy_document is overridden
# because mock_provider does not render a stable policy JSON document.
mock_provider "aws" {
  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:us-east-1:123456789012:unit-alarm-topic"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/unit-alarm-role"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/unit-alarm-policy"
    }
  }
}

override_data {
  target = data.aws_iam_policy_document.this
  values = {
    json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"SNS:Publish\",\"Principal\":{\"Service\":\"cloudwatch.amazonaws.com\"},\"Resource\":\"arn:aws:sns:us-east-1:123456789012:unit-alarm-topic\"}]}"
  }
}

variables {
  alarm_name        = "unit-alarm"
  alarm_description = "Unit alarm"
  alarm_comparison  = "GreaterThanThreshold"
  alarm_metric_type = "FreeStorageSpace"
  target_endpoint   = "https://example.com/hook"
  db_id             = "unit-db"
  event_rule_pattern = jsonencode({
    source = ["aws.rds"]
  })
}

run "metric_alarm_mode_creates_metric_alarm_only" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.database-storage-low-alarm) == 1
    error_message = "Metric mode should create one CloudWatch metric alarm."
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 0
    error_message = "Metric mode should not create an EventBridge rule."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.database-storage-low-alarm[0].dimensions.DBInstanceIdentifier == "unit-db"
    error_message = "Metric alarm should target the supplied DB identifier."
  }
}

run "event_mode_creates_event_rule_and_target_only" {
  command = plan

  variables {
    is_metric_alarm = false
    alarm_type      = "events"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.database-storage-low-alarm) == 0
    error_message = "Event mode should not create a metric alarm."
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 1
    error_message = "Event mode should create one EventBridge rule."
  }

  assert {
    condition     = aws_cloudwatch_event_target.this[0].target_id == "unit-alarm-target-id"
    error_message = "Event target id should be derived from alarm_name."
  }
}

run "defaults_and_computed_names_are_configured" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.database-storage-low-alarm[0].threshold == 75
    error_message = "Default threshold should be 75."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.database-storage-low-alarm[0].period == 300
    error_message = "Default alarm period should be 300 seconds."
  }

  assert {
    condition     = aws_iam_role.this.name == "unit-alarm-role"
    error_message = "IAM role name should be derived from alarm_name."
  }

  assert {
    condition     = aws_sns_topic.this.name == "unit-alarm-topic"
    error_message = "SNS topic name should be derived from alarm_name."
  }
}

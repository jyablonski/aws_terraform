# Snowflake-computed storage_aws_iam_user_arn and storage_aws_external_id are
# mocked here only so the generated IAM trust policy can be asserted locally.

mock_provider "snowflake" {
  mock_resource "snowflake_storage_integration" {
    defaults = {
      storage_aws_iam_user_arn = "arn:aws:iam::999999999999:user/snowflake"
      storage_aws_external_id  = "synthetic-external-id"
    }
  }
}

mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/unit-storage-role"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/unit-storage-role_policy"
    }
  }
}

variables {
  storage_integration_name  = "UNIT_STORAGE_INTEGRATION"
  storage_allowed_locations = "s3://unit-bucket/allowed/"
  storage_blocked_locations = "s3://unit-bucket/blocked/"
  bucket_name               = "unit-bucket"
  iam_role_name             = "unit-storage-role"
  aws_account_id            = "123456789012"
}

run "valid_inputs_configure_storage_integration" {
  command = plan

  assert {
    condition     = snowflake_storage_integration.this.name == "UNIT_STORAGE_INTEGRATION"
    error_message = "Storage integration name should come from storage_integration_name."
  }

  assert {
    condition     = snowflake_storage_integration.this.storage_aws_role_arn == "arn:aws:iam::123456789012:role/unit-storage-role"
    error_message = "Storage AWS role ARN should be derived from account id and role name."
  }

  assert {
    condition     = output.storage_integration_name == "UNIT_STORAGE_INTEGRATION"
    error_message = "storage_integration_name output should expose the integration name."
  }
}

run "iam_policy_targets_configured_bucket" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_policy.this.policy).Statement[0].Resource == "arn:aws:s3:::unit-bucket/*"
    error_message = "IAM policy object statement should target objects in bucket_name."
  }

  assert {
    condition     = jsondecode(aws_iam_policy.this.policy).Statement[1].Resource == "arn:aws:s3:::unit-bucket"
    error_message = "IAM policy bucket statement should target bucket_name."
  }
}

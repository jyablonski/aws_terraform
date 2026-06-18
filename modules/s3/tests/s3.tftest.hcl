# Mocked id and ARN values are synthetic and are not validated against real AWS
# provider behavior.
mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = {
      id  = "unit-bucket"
      arn = "arn:aws:s3:::unit-bucket"
    }
  }
}

override_resource {
  target          = aws_s3_bucket.this
  override_during = plan
  values = {
    id  = "unit-bucket"
    arn = "arn:aws:s3:::unit-bucket"
  }
}

variables {
  bucket_name         = "unit-bucket"
  s3_access_resources = ["arn:aws:iam::123456789012:role/unit-role"]
}

run "valid_inputs_configure_bucket_and_policy" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.bucket == "unit-bucket"
    error_message = "Bucket name should come directly from bucket_name."
  }

  assert {
    condition     = output.s3_bucket_name == "unit-bucket"
    error_message = "Bucket name output should expose the mocked bucket id."
  }

  assert {
    condition     = output.s3_bucket_arn == "arn:aws:s3:::unit-bucket"
    error_message = "Bucket ARN output should expose the mocked bucket ARN."
  }

  assert {
    condition     = length(jsondecode(aws_s3_bucket_policy.this.policy).Statement[0].Principal.AWS) == 1 && contains(jsondecode(aws_s3_bucket_policy.this.policy).Statement[0].Principal.AWS, "arn:aws:iam::123456789012:role/unit-role")
    error_message = "Bucket policy should grant access to the provided IAM principals."
  }
}

run "defaults_apply_private_acl_disabled_versioning_and_lifecycle" {
  command = plan

  assert {
    condition     = aws_s3_bucket_acl.this.acl == "private"
    error_message = "Default ACL should be private."
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Disabled"
    error_message = "Default versioning status should be Disabled."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this.rule[0].expiration[0].days == 7
    error_message = "Default lifecycle expiration should be 7 days."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this.rule[0].filter[0].prefix == "*"
    error_message = "Default lifecycle filter prefix should be *."
  }
}

run "custom_lifecycle_versioning_and_ownership_are_configured" {
  command = plan

  variables {
    prefix_expiration_length = 30
    prefix_expiration_name   = "tmp/"
    is_versioning_enabled    = "Enabled"
    object_ownership         = "BucketOwnerEnforced"
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should use the supplied status."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this.rule[0].id == "30-day-removal"
    error_message = "Lifecycle rule id should be derived from prefix_expiration_length."
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership == "BucketOwnerEnforced"
    error_message = "Ownership controls should use the supplied object ownership mode."
  }
}

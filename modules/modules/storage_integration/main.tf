# precalculating the IAM role ARN so storage integration can be created via this reference
locals {
  role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.iam_role_name}"
}

# resource "aws_s3_bucket" "this" {
#   bucket = var.bucket_name
# }

# resource "aws_s3_bucket_acl" "this" {
#   bucket = aws_s3_bucket.this.id
#   acl    = "private"
# }

# resource "aws_s3_bucket_notification" "module_bucket_notification" {
#   bucket = aws_s3_bucket.module_bucket.id

#   queue {
#     queue_arn     = "xx"
#     events        = ["s3:ObjectCreated:*"]
#     filter_suffix = var.file_suffix
#   }
# }

resource "snowflake_storage_integration" "this" {
  name    = var.storage_integration_name
  comment = var.storage_integration_comment
  type    = var.storage_integration_type

  enabled = true

  storage_allowed_locations = [var.storage_allowed_locations]
  storage_blocked_locations = [var.storage_blocked_locations]

  storage_provider = "S3"
  # storage_aws_external_id  = var.aws_external_id
  # storage_aws_iam_user_arn = var.aws_iam_user_arn
  storage_aws_role_arn = local.role_arn

}

resource "snowflake_integration_grant" "this" {
  integration_name = snowflake_storage_integration.this.name

  privilege = "USAGE"
  roles     = var.snowflake_integration_user_roles

  with_grant_option = false
}

resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${snowflake_storage_integration.this.storage_aws_iam_user_arn}"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "${snowflake_storage_integration.this.storage_aws_external_id}"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "this" {
  name = "${var.iam_role_name}_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::${var.bucket_name}",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "*"
                    ]
                }
            }
        },
        {
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey"
            ],
            "Effect": "Allow",
            "Resource": "${var.kms_key_arn}",
            "Sid": "KMSPolicyForSun"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
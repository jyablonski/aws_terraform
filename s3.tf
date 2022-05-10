resource "aws_s3_bucket" "jacobs_bucket_tf" {
  bucket = "jacobsbucket97"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket" "jacobs_bucket_tf_dev" {
  bucket = "jacobsbucket97-dev"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

# 1 config file per s3 bucket
# can add things like s3 files -> glacier after 90 days here etc.
resource "aws_s3_bucket_lifecycle_configuration" "jacobs_bucket_lifecycle_policy" {
  bucket = aws_s3_bucket.jacobs_bucket_tf.bucket

  rule {
    expiration {
      days = 60
    }

    filter {
      prefix = "sample_files/"
    }

    id     = "60-day-removal"
    status = "Enabled"
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "jacobs_bucket_lifecycle_policy_dev" {
  bucket = aws_s3_bucket.jacobs_bucket_tf_dev.bucket

  rule {
    id = "cost-reports"

    expiration {
      days = 90
    }

    filter {
      prefix = "cost-reports/"
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

  }

}

# 2022-03-21 fix this naming in the future
resource "aws_s3_bucket_acl" "jyablonski_bucket_tf_acl" {
  bucket = aws_s3_bucket.jacobs_bucket_tf.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "jyablonski_bucket_tf_acl_dev" {
  bucket = aws_s3_bucket.jacobs_bucket_tf_dev.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "jacobs_bucket_tf_access" {
  bucket = aws_s3_bucket.jacobs_bucket_tf.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "jacobs_bucket_tf_access_dev" {
  bucket = aws_s3_bucket.jacobs_bucket_tf_dev.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.jacobs_bucket_tf.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
        "${data.aws_caller_identity.current.account_id}"
        ]
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.jacobs_bucket_tf.arn}/*",
        "${aws_s3_bucket.jacobs_bucket_tf.arn}"
      ]
    }
  ]
}
EOF

}

resource "aws_s3_bucket_policy" "allow_access_from_another_account_dev" {
  bucket = aws_s3_bucket.jacobs_bucket_tf_dev.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
        "${data.aws_caller_identity.current.account_id}"
        ]
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.jacobs_bucket_tf_dev.arn}/*",
        "${aws_s3_bucket.jacobs_bucket_tf_dev.arn}"
      ]
    }
  ]
}
EOF

}

# this is how you would add default server side encryption-at-rest
# resource "aws_s3_bucket_server_side_encryption_configuration" "jacobs_bucket_encryption" {
#   bucket = aws_s3_bucket.jacobs_bucket_tf.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "AES256"
#     }
#   }
# }
locals {
  kinesis_role_name        = "jacobs_firehose_role"
  kinesis_job_name         = "jacobs_kinesis_job"
  kinesis_policy_name      = "jacobs_kinesis_policy"
  kinesis_logs_name        = "jacobs-kinesis-logs"
  kinesis_logs_stream_name = "jacobs-kinesis-logs-stream"
  kinesis_stream_name      = "jacobs-kinesis-stream"
  kinesis_firehose_name    = "jacobs-kinesis-firehose-stream"
  kinesis_bucket_name      = "jacobs-kinesis-bucket"
  project_name             = "kinesis-test"
}

resource "aws_iam_role" "jacobs_firehose_role" {
  name = local.kinesis_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "jacobs_kinesis_firehose_logs" {
  name              = local.kinesis_logs_name
  retention_in_days = 7
}

resource "aws_iam_policy" "jacobs_kinesis_firehose_policy" {
  name        = "jacobs_kinesis_firehose_policy"
  description = "Least-privilege policy for Firehose delivery to the Kinesis S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteToKinesisBucket"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
        ]
        Resource = [
          aws_s3_bucket.jacobs_kinesis_bucket.arn,
          "${aws_s3_bucket.jacobs_kinesis_bucket.arn}/*",
        ]
      },
      {
        Sid    = "WriteFirehoseLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "${aws_cloudwatch_log_group.jacobs_kinesis_firehose_logs.arn}:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = aws_iam_policy.jacobs_kinesis_firehose_policy.arn
}

resource "aws_s3_bucket" "jacobs_kinesis_bucket" {
  bucket = local.kinesis_bucket_name

  tags = {
    Environment = local.project_name
    Terraform   = local.Terraform
  }
}

resource "aws_s3_bucket_ownership_controls" "jacobs_kinesis_bucket_ownership" {
  bucket = aws_s3_bucket.jacobs_kinesis_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "kinesis_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.jacobs_kinesis_bucket_ownership]

  bucket = aws_s3_bucket.jacobs_kinesis_bucket.id
  acl    = "private"
}

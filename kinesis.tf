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

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment1" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment2" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment4" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
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

resource "aws_kinesis_firehose_delivery_stream" "jacobs_kinesis_firehose_stream" {
  name        = local.kinesis_firehose_name
  destination = "extended_s3"

  # data gets delivered to s3 in s3://jacobs-kinesis-bucket/2022/03/20/15/jacobs-kinesis-firehose-stream-1-2022-03-20-15-59-31-xxx
  extended_s3_configuration {
    role_arn           = aws_iam_role.jacobs_firehose_role.arn
    bucket_arn         = aws_s3_bucket.jacobs_kinesis_bucket.arn
    buffering_size     = 20  # store every 20 mb
    buffering_interval = 600 # or every 10 minutes

    prefix              = "kinesis-firehose/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "kinesis-firehose-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
    # data_format_conversion_configuration {} # used to change format of the data from json into something like (compressed) parquet
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.jacobs_kinesis_firehose_logs.name
      log_stream_name = local.kinesis_logs_stream_name
    }
  }

  tags = {
    Environment = local.project_name
    Terraform   = local.Terraform
  }
}


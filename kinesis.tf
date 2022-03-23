locals {
  kinesis_role_name     = "jacobs_firehose_role"
  kinesis_job_name      = "jacobs_kinesis_job"
  kinesis_policy_name   = "jacobs_kinesis_policy"
  kinesis_logs_name     = "jacobs-kinesis-logs"
  kinesis_stream_name   = "jacobs-kinesis-stream"
  kinesis_firehose_name = "jacobs-kinesis-firehose-stream"
  kinesis_bucket_name   = "jacobs-kinesis-bucket"
  project_name          = "kinesis-test"
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

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment1" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment2" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment3" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_kinesis_role_attachment4" {
  role       = aws_iam_role.jacobs_firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseReadOnlyAccess"
}

resource "aws_s3_bucket" "jacobs_kinesis_bucket" {
  bucket = local.kinesis_bucket_name

  tags = {
    Environment = local.project_name
    Terraform   = local.Terraform
  }
}

resource "aws_s3_bucket_acl" "kinesis_bucket_acl" {
  bucket = aws_s3_bucket.jacobs_kinesis_bucket.id
  acl    = "private"
}

# this creates the data stream - cancelling as of 2022-03-23 bc it costs money
# resource "aws_kinesis_stream" "jacobs_kinesis_stream" {
#   name             = local.kinesis_stream_name
#   shard_count      = 1
#   retention_period = 24
#   encryption_type  = "NONE"


#   stream_mode_details {
#     stream_mode = "PROVISIONED"
#   }

#   tags = {
#     Environment = local.project_name
#     Terraform   = local.Terraform
#   }
# }

# # this creates the delivery stream which connects TO the data stream above, and provides an output of where to store the data
# #  (s3, elasticsearch, redshift).
# # need to add error logging with the cloudwatch_logging_options config block
# resource "aws_kinesis_firehose_delivery_stream" "jacobs_kinesis_firehose_stream" {
#   name        = local.kinesis_firehose_name
#   destination = "extended_s3"

#   # data gets delivered to s3 in s3://jacobs-kinesis-bucket/2022/03/20/15/jacobs-kinesis-firehose-stream-1-2022-03-20-15-59-31-xxx
#   extended_s3_configuration {
#     role_arn   = aws_iam_role.jacobs_firehose_role.arn
#     bucket_arn = aws_s3_bucket.jacobs_kinesis_bucket.arn

#     # the idea is that you can use lambda to transform the data in the stream BEFORE it gets written to s3 / redshift / elasticsearch etc

#     # processing_configuration {
#     #   enabled = "true"

#     #   processors {
#     #     type = "Lambda"

#     #     parameters {
#     #       parameter_name  = "LambdaArn"
#     #       parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
#     #     }
#     #   }
#     # }
#   }

#   tags = {
#     Environment = local.project_name
#     Terraform   = local.Terraform
#   }
# }


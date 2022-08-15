locals {
  glue_role_name   = "jacobs_glue_role"
  glue_job_name    = "jacobs_glue_job"
  glue_policy_name = "jacobs_glue_policy"
  glue_logs_name   = "jacobs-glue-logs"
}

resource "aws_iam_policy" "glue_policy" {
  name        = local.glue_policy_name
  path        = "/"
  description = "Policy for Glue Jobs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "glue:*",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:GetBucketAcl",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeRouteTables",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "iam:ListRolePolicies",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "cloudwatch:PutMetricData"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:CreateBucket",
          "s3:PutBucketPublicAccessBlock"
        ],
        "Resource" : [
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::aws-glue-*/*",
          "arn:aws:s3:::*/*aws-glue-*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::crawler-public*",
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:AssociateKmsKey"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:/aws-glue/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "aws:TagKeys" : [
              "aws-glue-service-resource"
            ]
          }
        },
        "Resource" : [
          "arn:aws:ec2:*:*:network-interface/*",
          "arn:aws:ec2:*:*:security-group/*",
          "arn:aws:ec2:*:*:instance/*"
        ]
      }
    ]
  })
}



resource "aws_iam_role" "jacobs_glue_role" {
  name               = local.glue_role_name
  description        = "Role created for AWS Glue Prac"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_glue_role_attachment1" {
  role       = aws_iam_role.jacobs_glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_cloudwatch_log_group" "jacobs_glue_logs" {
  name              = local.glue_logs_name
  retention_in_days = 7
}

# resource "aws_glue_job" "jacobs_glue_job" {
#   name         = local.glue_job_name
#   role_arn     = aws_iam_role.jacobs_glue_role.arn
#   timeout      = 1      # 1 minute timeout
#   max_capacity = 0.0625 # use 1/16 data processing units
#   max_retries  = 0
#   glue_version = "3.0" # this allows spark 3.1.1 and python 3.7 i think?

#   command {
#     name            = "pythonshell"
#     script_location = "s3://${aws_s3_bucket.jacobs_bucket_tf.bucket}/practice/glue_ingest.py"
#     python_version  = 3
#   }

#   default_arguments = {
#     "--job-language"                     = "python"
#     "--continuous-log-logGroup"          = aws_cloudwatch_log_group.jacobs_glue_logs.name
#     "--enable-continuous-cloudwatch-log" = "true"
#     "--enable-continuous-log-filter"     = "true"
#     "--enable-metrics"                   = ""
#   }
# }
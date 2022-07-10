locals {
  env_type           = "Prod" # cant have an apostrophe in the tag name
  env_name           = "Jacobs TF Project"
  grafana_account_id = "008923505280"
  env_terraform      = true
  Terraform          = true
}

resource "aws_iam_role" "jacobs_ecs_role" {
  name               = "jacobs_ecs_role"
  description        = "Role created for AWS ECS"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "jacobs_ecs_role_attachment" {
  role       = aws_iam_role.jacobs_ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "jacobs_ecs_role_attachment_ses" {
  role       = aws_iam_role.jacobs_ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_ecs_role_attachment_s3" {
  role       = aws_iam_role.jacobs_ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role" "jacobs_ecs_ecr_role" {
  name               = "jacobs_ecs_ecr_role"
  description        = "Role created for AWS ECS ECR Access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "jacobs_ecs_ecr_role_attachment" {
  role       = aws_iam_role.jacobs_ecs_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

# this is a private repo by default.  use aws_ecrpublic_repository for a public repo.

resource "aws_iam_group" "jacobs_github_group" {
  name = "github-ecr-cicd"
}

resource "aws_iam_user" "jacobs_github_user" {
  name = "jacobs-github-ci"

}

resource "aws_iam_group_membership" "jacobs_github_group_attach" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.jacobs_github_user.name
  ]

  group = aws_iam_group.jacobs_github_group.name
}

resource "aws_iam_group_policy_attachment" "jacobs_github_group_policy_attach" {
  group      = aws_iam_group.jacobs_github_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

##
resource "aws_iam_user" "jacobs_airflow_user" {
  name = "jacobs_airflow_user"

}

resource "aws_iam_user_policy_attachment" "jacobs_airflow_user_attachment" {
  user       = aws_iam_user.jacobs_airflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_user_policy_attachment" "jacobs_airflow_user_attachment_execution" {
  user       = aws_iam_user.jacobs_airflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_user_policy_attachment" "jacobs_airflow_user_attachment_ses" {
  user       = aws_iam_user.jacobs_airflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_user_policy_attachment" "jacobs_airflow_user_attachment_ecr" {
  user       = aws_iam_user.jacobs_airflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_iam_user_policy_attachment" "jacobs_airflow_user_attachment_s3" {
  user       = aws_iam_user.jacobs_airflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "jacobs_airflow_user_attachment_ssm" {
  user       = aws_iam_user.jacobs_airflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "jacobs_airflow_user_attachment_cloudwatch_logs" {
  user       = aws_iam_user.jacobs_airflow_user.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}

# use this to create schemas from now on.

##################
#                #
#    POSTGRES    #  Removing as of 12-12-21
#                #
# ##################

# provider "postgresql" {
#   host     = var.pg_host
#   username = var.pg_user
#   password = var.pg_pass
# }

# terraform {
# required_providers {
#   postgresql = {
#     source = "cyrilgdn/postgresql"
#     version = "1.14.0"
#   }
# }
# }

# resource "postgresql_database" "jacobs_practice_db" {
#   name = "jacobs_practice_db"
#   owner = var.pg_user
# }

# resource "postgresql_schema" "jacobs_practice_schema" {
#   name  = "jacobs_practice_schema"
#   database = postgresql_database.jacobs_practice_db.name
#   owner = var.pg_user
# }

# resource "postgresql_role" "jacobs_dbt_role" {
#   name     = "jacobs_dbt_role"
#   password = var.pg_pass
# }

# resource "postgresql_schema" "my_practice_schema" {
#   name  = "my_practice_schema"
#   owner = var.pg_user
# }

# resource "postgresql_schema" "nba_prep" {
#   name  = "nba_prep"
#   owner = var.pg_user
# }

resource "aws_ssm_parameter" "jacobs_ssm_prac_public" {
  name  = "jacobs_ssm_test"
  type  = "String"
  value = "bar"
}

resource "aws_ssm_parameter" "jacobs_ssm_prac_secret" {
  name        = "jacobs_ssm_pg_user"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.pg_user

}

resource "aws_ssm_parameter" "jacobs_ssm_subnet1" {
  name        = "jacobs_ssm_subnet1"
  description = "Public Subnet 1"
  type        = "SecureString"
  value       = aws_subnet.jacobs_public_subnet.id

}

resource "aws_ssm_parameter" "jacobs_ssm_subnet2" {
  name        = "jacobs_ssm_subnet2"
  description = "Public Subnet 2"
  type        = "SecureString"
  value       = aws_subnet.jacobs_public_subnet_2.id

}

resource "aws_ssm_parameter" "jacobs_ssm_sg_task" {
  name        = "jacobs_ssm_sg_task"
  description = "RDS Security Group for Tasks"
  type        = "SecureString"
  value       = aws_security_group.jacobs_task_security_group_tf.id

}

## airflow ssm vars
resource "aws_ssm_parameter" "jacobs_ssm_rds_db_name" {
  name        = "jacobs_ssm_rds_db_name"
  description = "RDS DB Name"
  type        = "SecureString"
  value       = var.jacobs_rds_db

}

resource "aws_ssm_parameter" "jacobs_ssm_rds_host" {
  name        = "jacobs_ssm_rds_host"
  description = "RDS Host IP"
  type        = "SecureString"
  value       = aws_db_instance.jacobs_rds_tf.address

}

resource "aws_ssm_parameter" "jacobs_ssm_rds_user" {
  name        = "jacobs_ssm_rds_user"
  description = "RDS Username"
  type        = "SecureString"
  value       = var.jacobs_rds_user

}

resource "aws_ssm_parameter" "jacobs_ssm_rds_pw" {
  name        = "jacobs_ssm_rds_pw"
  description = "RDS Host IP"
  type        = "SecureString"
  value       = var.jacobs_rds_pw

}

resource "aws_ssm_parameter" "jacobs_ssm_rds_schema" {
  name        = "jacobs_ssm_rds_schema"
  description = "RDS Schema"
  type        = "SecureString"
  value       = var.jacobs_rds_schema

}

resource "aws_ssm_parameter" "jacobs_ssm_dbt_prac_key" {
  name        = "jacobs_ssm_dbt_prac_key"
  description = "dbt prac key"
  type        = "String"
  value       = "dbt_docker_test"

}


## Lambda Event-Driven Workflow zz
resource "aws_s3_bucket" "jyablonski_lambda_bucket" {
  bucket = "jyablonski-lambda-bucket"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket_acl" "jyablonski_lambda_bucket_acl" {
  bucket = aws_s3_bucket.jyablonski_lambda_bucket.id
  acl    = "private"
}

# these aws resources assume these roles, so the assume_role_policy is saying WHICH aws service can assume this role
# so ecs, ecr, in this case lambda
resource "aws_iam_role" "jacobs_lambda_s3_role" {
  name               = "jacobs_lambda_s3_role"
  description        = "Role created for AWS Lambda S3 File Detection"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "lambda-sns-policy"
  description = "A test policy for lambdasto publish to sns"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid":"AllowPublishToMyTopic",
        "Effect":"Allow",
        "Action":"sns:Publish",
        "Resource":"arn:aws:sns:us-east-1:324816727452:jacobs-first-sns-topic"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_role_attachment1" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::324816727452:policy/service-role/AWSLambdaBasicExecutionRole-6777176a-f601-4ad8-864d-53578dfceb07"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_role_attachment2" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_role_attachment3" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::324816727452:policy/service-role/AWSLambdaS3ExecutionRole-2f559d56-d564-4348-abc7-3afe33f407c6"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_attachment_4" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_attachment_5" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_attachment_6" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}


# heads up u literally have to like rename the file (python2 -> python3 etc) for any changes in main.py to get reflected in tf.
data "archive_file" "default" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda_s3_notification/"
  output_path = "${path.module}/myzip/python3.zip"
}

resource "aws_cloudwatch_log_group" "jacobs_lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "jacobs_sqs_lambda_logs" {
  name              = "/aws/lambda/jacobs_sqs_lambda_function"
  retention_in_days = 14
}

resource "aws_iam_policy" "jacobs_lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = aws_iam_policy.jacobs_lambda_logging.arn
}

resource "aws_lambda_function" "jacobs_s3_lambda_function" {
  filename      = "${path.module}/myzip/python3.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.jacobs_lambda_s3_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.lambda_logs]
}

resource "aws_lambda_permission" "allow_bucket1" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_s3_lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.jyablonski_lambda_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.jyablonski_lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.jacobs_s3_lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
}

resource "aws_iam_user" "jacobs_terraform_user" {
  name = "jacobs-terraform-user"

}

resource "aws_iam_user_policy_attachment" "jacobs_terraform_user_attachment" {
  user       = aws_iam_user.jacobs_terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_s3_bucket" "jyablonski_unhappy_bucket" {
  bucket = "jyablonski-unhappy-bucket"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket_acl" "jyablonski_unhappy_bucket_acl" {
  bucket = aws_s3_bucket.jyablonski_unhappy_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "jyablonski_tf_cicd_bucket" {
  bucket = "jyablonski-tf-cicd-bucket"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket_acl" "jyablonski_tf_cicd_bucket_acl" {
  bucket = aws_s3_bucket.jyablonski_tf_cicd_bucket.id
  acl    = "private"
}



#########
# resource "aws_lambda_permission" "allow_bucket_jacobsbucket97" {
#   statement_id  = "AllowExecutionFromS3Bucketjacobsbucket97"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.jacobs_s3_lambda_function.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.jacobs_bucket_tf.arn
# }

# resource "aws_s3_bucket_notification" "bucket_notification_jacobsbucket97" {
#   bucket = aws_s3_bucket.jacobs_bucket_tf.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.jacobs_s3_lambda_function.arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "boxscores/"
#     filter_suffix       = ".parquet"
#   }
# }

## SQS - LAMBDA - S3 BUCKET TRANSACTIONS
resource "aws_s3_bucket" "jacobs_sqs_sns_bucket" {
  bucket = "jacobs-sqs-bucket"
  tags = {
    Name        = local.env_name
    Environment = local.env_type
    Terraform   = local.env_terraform
  }
}

resource "aws_s3_bucket_acl" "jacobs_sqs_sns_bucket_acl" {
  bucket = aws_s3_bucket.jacobs_sqs_sns_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_sqs" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda_sqs/"
  output_path = "${path.module}/myzip/lambda_sqs8.zip"
}

resource "aws_lambda_function" "jacobs_s3_sqs_lambda_function" {
  filename      = "${path.module}/myzip/lambda_sqs8.zip"
  function_name = "jacobs_sqs_lambda_function"
  role          = aws_iam_role.jacobs_lambda_s3_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.lambda_logs]
}

# resource "aws_s3_bucket_notification" "bucket_notification_jacobsbucket97_sqs" {
#   bucket = aws_s3_bucket.jacobs_bucket_tf.id

#   queue {
#     id                  = "jacobs-sqs-lambda-trigger"
#     queue_arn           = aws_sqs_queue.jacobs_sqs_queue.arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "transactions/"
#     filter_suffix       = ".parquet"
#   }

# }

### SNS - LAMBDA - S3 BUCKET REDDIT DATA
resource "aws_sns_topic" "jacobs_sns_topic" {
  name       = "jacobs-first-sns-topic"
  fifo_topic = false

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:jacobs-first-sns-topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.jacobs_sqs_sns_bucket.arn}"}
        }
    }]
}
POLICY
  tags = {
    Name        = local.env_name
    Environment = local.env_type
    Terraform   = local.env_terraform
  }
}

resource "aws_sqs_queue" "jacobs_sqs_queue" {
  name                       = "jacobs-first-sqs"
  delay_seconds              = 0
  message_retention_seconds  = 480    # 4 days
  max_message_size           = 262144 # 256 KiB
  visibility_timeout_seconds = 120

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
                "Service": "sns.amazonaws.com"
            },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:jacobs-first-sqs",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_sns_topic.jacobs_sns_topic.arn}" }
      }
    }
  ]
}
POLICY

  tags = {
    Name        = local.env_name
    Environment = local.env_type
    Terraform   = local.env_terraform
  }
}

resource "aws_lambda_permission" "allow_bucket_sqs" {
  statement_id  = "AllowExecutionFromS3Bucketsqs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_s3_sqs_lambda_function.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.jacobs_sqs_queue.arn
}


# resource "aws_lambda_permission" "allow_bucket_sns" {
#   statement_id  = "AllowExecutionFromS3Bucketsns"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.jacobs_s3_sqs_lambda_function.arn
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.jacobs_sns_topic.arn
# }


resource "aws_sns_topic_subscription" "enable_lambda_sns" {
  topic_arn = aws_sns_topic.jacobs_sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.jacobs_sqs_queue.arn
}

resource "aws_lambda_event_source_mapping" "enable_lambda_sqs" {
  event_source_arn = aws_sqs_queue.jacobs_sqs_queue.arn
  function_name    = aws_lambda_function.jacobs_s3_sqs_lambda_function.arn
}

resource "aws_s3_bucket_notification" "bucket_notification_sqs_sns" {
  bucket = aws_s3_bucket.jacobs_sqs_sns_bucket.id

  topic {
    topic_arn     = aws_sns_topic.jacobs_sns_topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "reddit_data/"
    filter_suffix = ".parquet"
  }

  # lambda_function {
  #   lambda_function_arn = aws_lambda_function.jacobs_s3_lambda_function.arn
  #   events              = ["s3:ObjectCreated:*"]
  #   filter_prefix       = "boxscores/"
  #   filter_suffix       = ".parquet"
  # }

  # queue {
  #   queue_arn           = aws_sqs_queue.jacobs_sqs_queue.arn
  #   events              = ["s3:ObjectCreated:*"]
  #   filter_prefix       = "transactions/"
  #   filter_suffix       = ".parquet"
  # }

  depends_on = [aws_lambda_permission.allow_bucket_sqs,
  ]
}

resource "aws_iam_user" "jacobs_github_s3_user" {
  name = "jacobs_github_s3_user"

}

resource "aws_iam_policy" "github_s3_policy" {
  name        = "jacobsbucket97_github_s3_policy"
  description = "A Policy for GitHub Actions to write to S3 Bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_tf_dev.bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_tf_dev.bucket}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "jacobs_github_s3_user_attachment" {
  user       = aws_iam_user.jacobs_github_s3_user.name
  policy_arn = aws_iam_policy.github_s3_policy.arn
}
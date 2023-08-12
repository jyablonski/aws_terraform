locals {
  env_type      = "Prod" # cant have an apostrophe in the tag name
  env_name      = "Jacobs TF Project"
  env_terraform = true
  Terraform     = true
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

resource "aws_iam_policy" "ecs_ec2_cs_role_policy_sts" {
  name        = "${local.ecs_cluster_name}-cs-sts-policy"
  description = "A test policy for cs iam role to run ecs cluster tasks"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole"
          ],
          "Resource": [
            "arn:aws:iam::288364792694:role/jacobs-ecs-ec2-cluster-cs-role"
          ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_ecs_role_attachment_cs_sts" {
  role       = aws_iam_role.jacobs_ecs_role.name
  policy_arn = aws_iam_policy.ecs_ec2_cs_role_policy_sts.arn
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
        "Resource":"arn:aws:sns:us-east-1:288364792694:jacobs-first-sns-topic"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_role_attachment1" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_role_attachment2" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_s3_role_attachment3" {
  role       = aws_iam_role.jacobs_lambda_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonS3ObjectLambdaExecutionRolePolicy"
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
resource "aws_cloudwatch_log_group" "jacobs_lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "jacobs_sqs_lambda_logs" {
  name              = "/aws/lambda/jacobs_sqs_lambda_function"
  retention_in_days = 14
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

resource "aws_key_pair" "airflow_ec2_key" {
  key_name   = "airflow-ec2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDASt11D8SVlSNJX1/fPdQjipLkfFZrIjbmBwnr4wUMXw+2TogUmJnMI3of8Gv297CE/Zz9VVJMO2Z2+R2Uy/XllhyuQNUYOzD6B7fBm0i/HXhJ1kZwh1DjB1vtOn3rwBVF2ZuXp5gBAdp6welZ2uWzDLB/34lKN89WPNS7f/H//eYLbCrM4e8a2qgbuHqUOMlxida1N6zWgV1Jt1962H3Dd09tEN0H2yGZIUGiGtvSvbvF+YJO6cz7XJ2fU9zJifLBJ6oyfj1DdlScOqTXhpF5KNbx6czJFgwx+oRhCariBt4q4RvRSGt4t73XyIczDYDzyMnQXKQgb7XSOVgTRmyQLwwys+l4fpyE9uOfHkL1RtTAVRbylxVBVsxYt8xYSNyRUNsHLJRBCqRPYCJHLKwJrjyFdvh3u1XBazCNOrYQycHwl6Te8JmfrdESfshzheBUCFw6ZXLGCI8saqQgFh83vj+HkiOVd64H3U2fsijABmLK/YsczTtX39iKyB9Z2rU= jacob@jacob-BigOtisLinux"
}

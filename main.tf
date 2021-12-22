locals {
    env_type = "Prod" # cant have an apostrophe in the tag name
    env_name = "Jacobs TF Project"
    grafana_account_id = "008923505280"
}

resource "aws_vpc" "jacobs_vpc_tf" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "Jacobs VPC"
    Environment = local.env_type
  }
}

resource "aws_s3_bucket" "jacobs_bucket_tf" {
  bucket = "jacobsbucket97"
  acl    = "private"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

# attach this to things like aws lambda or ecs tasks so they can connect to the rds database
resource "aws_security_group" "jacobs_task_security_group_tf"{
    name = "jacobs_security_group for tasks"
    description = "Connect Tasks to RDS"
    vpc_id = aws_vpc.jacobs_vpc_tf.id

    ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_security_group" "jacobs_rds_security_group_tf" {
  name        = "jacobs_security_group for rds"
  description = "Allow Jacobs Traffic to RDS"
  vpc_id      = aws_vpc.jacobs_vpc_tf.id

  ingress {
    description      = "Custom IP Addresses"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = var.jacobs_cidr_block

  }

  ingress {
    description      = "Other Security Groups"
    from_port        = -1
    to_port          = -1
    protocol         = "all"
    security_groups  = [aws_security_group.jacobs_task_security_group_tf.id]
  }


  # outbound
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_subnet" "jacobs_public_subnet" {
  vpc_id     = aws_vpc.jacobs_vpc_tf.id
  cidr_block = cidrsubnet(aws_vpc.jacobs_vpc_tf.cidr_block, 8, 1)
  map_public_ip_on_launch = true

  tags = {
    Name        = "Jacobs Public Subnet"
    Environment = local.env_type
  }
}

resource "aws_subnet" "jacobs_public_subnet_2" {
  vpc_id     = aws_vpc.jacobs_vpc_tf.id
  cidr_block = cidrsubnet(aws_vpc.jacobs_vpc_tf.cidr_block, 8, 3)
  map_public_ip_on_launch = true

  tags = {
    Name        = "Jacobs Public Subnet 2"
    Environment = local.env_type
  }
}

resource "aws_db_subnet_group" "jacobs_subnet_group" {
  name = "jacobs-subnet-group"
  subnet_ids = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id]

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_internet_gateway" "jacobs_gw" {
  vpc_id = aws_vpc.jacobs_vpc_tf.id

  tags = {
    Name        = "Jacobs Gateway"
    Environment = local.env_type
  }
}

resource "aws_route_table" "jacobs_public_route_table" {
  vpc_id = aws_vpc.jacobs_vpc_tf.id

  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.jacobs_gw.id
      carrier_gateway_id = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id = ""
      instance_id = ""
      ipv6_cidr_block = ""
      local_gateway_id = ""
      nat_gateway_id = ""
      network_interface_id = ""
      transit_gateway_id = ""
      vpc_endpoint_id = ""
      vpc_peering_connection_id = ""
    }
  ]
  tags = {
    Name        = "Jacobs Public Route Table"
    Environment = local.env_type
  }
}

resource "aws_route_table_association" "jacobs_public_route" {
  subnet_id      = aws_subnet.jacobs_public_subnet.id
  route_table_id = aws_route_table.jacobs_public_route_table.id

}

resource "aws_route_table_association" "jacobs_public_route_2" {
  subnet_id      = aws_subnet.jacobs_public_subnet_2.id
  route_table_id = aws_route_table.jacobs_public_route_table.id

}

# original mysql server - gbye my sweet prince
# resource "aws_db_instance" "jacobs_rds_tf" {
#   allocated_storage    = 20
#   max_allocated_storage = 21
#   engine               = "mysql"
#   engine_version       = "8.0" # try this or 8.0.23
#   instance_class       = "db.t2.micro"
#   identifier           = "jacobs-rds-server"
#   port                 = 3306
#   name                 = "jacob_db"   # this is the name of the default database that will be created.
#   username             = var.jacobs_rds_user
#   password             = var.jacobs_rds_pw
#   # parameter_group_name = "default.mysql8.0.25" # try this
#   skip_final_snapshot  = true
#   publicly_accessible  = true
#   storage_type         = "gp2" # general purpose ssd
#   vpc_security_group_ids = [aws_security_group.jacobs_rds_security_group_tf.id]
#   db_subnet_group_name = aws_db_subnet_group.jacobs_subnet_group.id

#   tags = {
#     Name        = local.env_name
#     Environment = local.env_type
#   }

# }

resource "aws_db_instance" "jacobs_rds_tf" {
  allocated_storage    = 20
  max_allocated_storage = 21
  engine               = "postgres"
  engine_version       = "12.7" # newest possible version that's in free tier eligiblity
  instance_class       = "db.t2.micro"
  identifier           = "jacobs-rds-server"
  port                 = 5432
  name                 = "jacob_db"   # this is the name of the default database that will be created.
  username             = var.jacobs_rds_user
  password             = var.jacobs_rds_pw
  # parameter_group_name = "default.mysql8.0.25" # try this
  skip_final_snapshot  = true
  publicly_accessible  = true
  storage_type         = "gp2" # general purpose ssd
  vpc_security_group_ids = [aws_security_group.jacobs_rds_security_group_tf.id]
  db_subnet_group_name = aws_db_subnet_group.jacobs_subnet_group.id

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }

}

resource "aws_iam_role" "jacobs_ecs_role" {
  name = "jacobs_ecs_role"
  description = "Role created for AWS ECS"
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
  name = "jacobs_ecs_ecr_role"
  description = "Role created for AWS ECS ECR Access"
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
resource "aws_ecr_repository" "jacobs_repo" {
  name                 = "jacobs_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "jacobs_repo_policy" {
  repository = aws_ecr_repository.jacobs_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Remove old images",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

## STOP at this step and upload docker image to this repo.  format below
# docker tag jacobs-python-docker-2:latest 324816727452.dkr.ecr.us-east-1.amazonaws.com/jacobs_repo:latest
# docker push 324816727452.dkr.ecr.us-east-1.amazonaws.com/jacobs_repo:latest

resource "aws_cloudwatch_log_group" "aws_ecs_logs" {
  name = "jacobs_ecs_logs"
  retention_in_days = 30

}

resource "aws_cloudwatch_log_group" "aws_ecs_logs_airflow" {
  name = "jacobs_ecs_logs_airflow"
  retention_in_days = 30

}

resource "aws_ecs_cluster" "jacobs_ecs_cluster" {
  name = "jacobs_fargate_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# cloudwatch log stuff would go in the container defintion part with logConfiguration
resource "aws_ecs_task_definition" "jacobs_ecs_task" {
  family                = "jacobs_task"
  container_definitions = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:latest",
        "name": "jacobs_container",
        "environment": [
          {"name": "IP", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "PORT", "value": "5432"},
          {"name": "RDS_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "RDS_PW", "value": "${var.jacobs_rds_pw}"},
          {"name": "RDS_DB", "value": "jacob_db"},
          {"name": "reddit_user", "value": "${var.jacobs_reddit_user}"},
          {"name": "reddit_pw", "value": "${var.jacobs_reddit_pw}"},
          {"name": "reddit_accesskey", "value": "${var.jacobs_reddit_accesskey}"},
          {"name": "reddit_secretkey", "value": "${var.jacobs_reddit_secretkey}"},
          {"name": "USER_PW", "value": "${var.jacobs_pw}"},
          {"name": "USER_EMAIL", "value": "${var.jacobs_email_address}"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "jacobs_ecs_logs",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  execution_role_arn = aws_iam_role.jacobs_ecs_role.arn # permissions needed for pulling ecr or writing to cloudwatch logs etc
  task_role_arn = aws_iam_role.jacobs_ecs_role.arn      # the actual permissions needed for when code runs (s3 access, ses access etc)
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "jacobs_ecs_task_airflow" {
  family                = "jacobs_task_airflow"
  container_definitions = <<TASK_DEFINITION
[
    {
        "image": "${aws_ecr_repository.jacobs_repo.repository_url}:nba_airflow",
        "name": "jacobs_container_airflow",
        "environment": [
          {"name": "IP", "value": "${aws_db_instance.jacobs_rds_tf.address}"},
          {"name": "PORT", "value": "5432"},
          {"name": "RDS_USER", "value": "${var.jacobs_rds_user}"},
          {"name": "RDS_PW", "value": "${var.jacobs_rds_pw}"},
          {"name": "RDS_DB", "value": "jacob_db"},
          {"name": "reddit_user", "value": "${var.jacobs_reddit_user}"},
          {"name": "reddit_pw", "value": "${var.jacobs_reddit_pw}"},
          {"name": "reddit_accesskey", "value": "${var.jacobs_reddit_accesskey}"},
          {"name": "reddit_secretkey", "value": "${var.jacobs_reddit_secretkey}"},
          {"name": "USER_PW", "value": "${var.jacobs_pw}"},
          {"name": "USER_EMAIL", "value": "${var.jacobs_email_address}"},
          {"name": "S3_BUCKET", "value": "${var.jacobs_bucket}"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "jacobs_ecs_logs_airflow",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
        }
    } 
]
TASK_DEFINITION
  execution_role_arn = aws_iam_role.jacobs_ecs_role.arn # aws managed role to give permission to private ecr repo i just made.
  task_role_arn = aws_iam_role.jacobs_ecs_role.arn
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_cloudwatch_event_rule" "every_15_mins" {
  name = "python_scheduled_task_test" # change this name
  description = "Run every 15 minutes"
  schedule_expression = "cron(0/15 * * * ? *)"
}

resource "aws_cloudwatch_event_rule" "etl_rule" {
  name = "python_scheduled_task_prod" # change this name
  description = "Run every day at 12PM UTC"
  schedule_expression = "cron(0 12 * * ? *)"
}


# # # uncomment the block below when nba season starts and change the rule to etl_rule instead of every_15_min
resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "jacobs_target_id"
  arn = aws_ecs_cluster.jacobs_ecs_cluster.arn
  rule = aws_cloudwatch_event_rule.etl_rule.name
  role_arn  = aws_iam_role.jacobs_ecs_ecr_role.arn

  ecs_target {
    launch_type = "FARGATE"
    network_configuration {
      subnets = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id] # do not use subnet group here - wont work.  need list of the individual subnet ids.
      security_groups = [aws_security_group.jacobs_task_security_group_tf.id]
      assign_public_ip = true
    }
    platform_version = "LATEST"
    task_count = 1
    task_definition_arn = aws_ecs_task_definition.jacobs_ecs_task.arn
  }
}

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

## Lambda Event-Driven Workflow zz
resource "aws_s3_bucket" "jyablonski_lambda_bucket" {
  bucket = "jyablonski-lambda-bucket"
  acl    = "private"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

# these aws resources assume these roles, so the assume_role_policy is saying WHICH aws service can assume this role
# so ecs, ecr, in this case lambda
resource "aws_iam_role" "jacobs_lambda_s3_role" {
  name = "jacobs_lambda_s3_role"
  description = "Role created for AWS Lambda S3 File Detection"
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

data "archive_file" "default" {
  type        = "zip"
  source_dir  = "${path.module}/files/"
  output_path = "${path.module}/myzip/python2.zip"
}

resource "aws_cloudwatch_log_group" "jacobs_lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
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
  filename                       = "${path.module}/myzip/python2.zip"
  function_name                  = var.lambda_function_name
  role                           = aws_iam_role.jacobs_lambda_s3_role.arn
  handler                        = "main.lambda_handler"
  runtime                        = "python3.8"
  depends_on                     = [aws_iam_role_policy_attachment.lambda_logs]
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
  acl    = "private"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket" "jyablonski_tf_cicd_bucket" {
  bucket = "jyablonski-tf-cicd-bucket"
  acl    = "private"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

variable "region"{
    type = string
    sensitive = true
}

variable "access_key"{
    type = string
    sensitive = true
}

variable "secret_key"{
    type = string
    sensitive = true
}

variable "jacobs_cidr_block"{
    type = list(string)
    sensitive = true
}

variable "jacobs_rds_user" {
    type = string
    sensitive = true
}

variable "jacobs_rds_pw" {
    type = string
    sensitive = true
}

provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key

}

locals {
    env_type = "Dev" # cant have an apostrophe in the tag name
    env_name = "Jacobs TF Project"
}

resource "aws_default_vpc" "jacobs_vpc_tf" {

  tags = {
    Name        = local.env_name
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
    vpc_id = aws_default_vpc.jacobs_vpc_tf.id

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
  vpc_id      = aws_default_vpc.jacobs_vpc_tf.id

  ingress {
    description      = "Custom IP Addresses"
    from_port        = 3306
    to_port          = 3306
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

resource "aws_db_instance" "jacobs_rds_tf" {
  allocated_storage    = 20
  max_allocated_storage = 21
  engine               = "mysql"
  engine_version       = "8.0" # try this or 8.0.23
  instance_class       = "db.t2.micro"
  identifier = "jacobs-rds-server"
  port                 = 3306
  name                 = "jacob_db"
  username             = var.jacobs_rds_user
  password             = var.jacobs_rds_pw
  # parameter_group_name = "default.mysql8.0.25" # try this
  skip_final_snapshot  = true
  publicly_accessible  = true
  storage_type         = "gp2" # general purpose ssd
  vpc_security_group_ids = [aws_security_group.jacobs_rds_security_group_tf.id]

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }

}
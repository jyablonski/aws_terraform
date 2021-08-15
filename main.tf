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

resource "aws_security_group" "jacobs_rds_security_group_tf" {
  name        = "jacobs_security_group for rds"
  description = "Allow Jacobs Traffic to RDS"
  vpc_id      = aws_default_vpc.jacobs_vpc_tf.id # needs to get changed

  # inbound rules to let these resources ACCESS / WRITE TO the database.
  # need to put in like 7 different ip addresses
  # TO DO - Complete inbound access rules.
  
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
    security_groups  = ["sg-edbb7ff3"] # create a separate SG here for only aws lambda/ecs objects to access so they can connect to RDS
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

# resource "aws_db_instance" "jacobs_rds_tf" {
#   allocated_storage    = 20
#   max_allocated_storage = 21
#   engine               = "mysql"
#   engine_version       = "8.0" # try this or 8.0.23
#   instance_class       = "db.t2.micro"
#   port                 = 3306
#   name                 = "jacob_db"
#   username             = "user"
#   password             = "jacobpass123"
#   parameter_group_name = "default.mysql8.0.25" # try this
#   skip_final_snapshot  = true
#   publicly_accessible  = false
#   storage_type         = "gp2" # general purpose ssd

#   tags = {
#     Name        = local.env_name
#     Environment = local.env_type
#   }

# }
provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key

}

locals {
    env_type = "Prod" # cant have an apostrophe in the tag name
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
  name                 = "jacob_db"   # this is the name of the default database that will be created.
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

#### gateways, route tables, subnets for lambda functionality
resource "aws_subnet" "jacobs_public_subnet" {
  vpc_id     = aws_default_vpc.jacobs_vpc_tf.id
  cidr_block = aws_default_vpc.jacobs_vpc_tf.cidr_block # idk what to put here or how to make it automatically select a valid cidr block
  map_public_ip_on_launch = true

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_subnet" "jacobs_private_subnet" {
  vpc_id     = aws_default_vpc.jacobs_vpc_tf.id
  cidr_block = aws_default_vpc.jacobs_vpc_tf.cidr_block # idk what to put here or how to make it automatically select a valid cidr block

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_internet_gateway" "jacobs_gw" {
  vpc_id = aws_default_vpc.jacobs_vpc_tf.id

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_eip" "jacobs_eip" {
  vpc = true
  network_interface = aws_network_interface.jacobs_network_interface.id
  depends_on                = [aws_internet_gateway.jacobs_gw]
}

resource "aws_nat_gateway" "jacobs_nat_gw" {
  allocation_id = aws_eip.jacobs_eip.id
  subnet_id     = aws_subnet.jacobs_public_subnet.id

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }

  depends_on = [aws_internet_gateway.jacobs_gw]
}

resource "aws_route_table" "jacobs_private_route_table" {
  vpc_id = aws_default_vpc.jacobs_vpc_tf.id
  nat_gateway_id = aws_nat_gateway.jacobs_nat_gw.id

  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.jacobs_nat_gw.id
    }
  ]

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_route_table" "jacobs_public_route_table" {
  vpc_id = aws_default_vpc.jacobs_vpc_tf.id
  gateway_id = aws_internet_gateway.jacobs_gw.id

  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.jacobs_gw.id
    }
  ]
  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_route_table_association" "jacobs_private_route" {
  subnet_id      = aws_subnet.jacobs_private_subnet.id
  route_table_id = aws_route_table.jacobs_private_route_table.id

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_route_table_association" "jacobs_public_route" {
  subnet_id      = aws_subnet.jacobs_public_subnet.id
  route_table_id = aws_route_table.jacobs_public_route_table.id

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_network_interface" "jacobs_network_interface" {
  subnet_id       = aws_subnet.jacobs_public_subnet.id
  private_ips     = ["10.0.0.50"] # idk what to put here or how to make it automatic 

  attachment {
    instance     = aws_nat_gateway.jacobs_nat_gw.id
    device_index = 1
  }

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}
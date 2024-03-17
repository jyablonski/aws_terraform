resource "aws_vpc" "jacobs_vpc_tf" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  # assign_generated_ipv6_cidr_block = true

  tags = {
    Name        = "Jacobs VPC"
    Environment = local.env_type
  }
}

# attach this to things like aws lambda or ecs tasks so they can connect to the rds database
resource "aws_security_group" "jacobs_task_security_group_tf" {
  name        = "jacobs_security_group for tasks"
  description = "Connect Tasks to RDS"
  vpc_id      = aws_vpc.jacobs_vpc_tf.id

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
    description = "Custom IP Addresses"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.jacobs_cidr_block

  }

  ingress {
    description = "Open Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Other Security Groups"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.jacobs_task_security_group_tf.id]
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
  vpc_id                  = aws_vpc.jacobs_vpc_tf.id
  cidr_block              = cidrsubnet(aws_vpc.jacobs_vpc_tf.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name        = "Jacobs Public Subnet"
    Environment = local.env_type
  }
}

resource "aws_subnet" "jacobs_public_subnet_2" {
  vpc_id                  = aws_vpc.jacobs_vpc_tf.id
  cidr_block              = cidrsubnet(aws_vpc.jacobs_vpc_tf.cidr_block, 8, 3)
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name        = "Jacobs Public Subnet 2"
    Environment = local.env_type
  }
}

resource "aws_db_subnet_group" "jacobs_subnet_group" {
  name       = "jacobs-subnet-group"
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

  route {
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = aws_internet_gateway.jacobs_gw.id
    carrier_gateway_id         = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    # instance_id                = null
    ipv6_cidr_block           = null
    local_gateway_id          = null
    nat_gateway_id            = null
    network_interface_id      = null
    transit_gateway_id        = null
    vpc_endpoint_id           = null
    vpc_peering_connection_id = null
  }

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

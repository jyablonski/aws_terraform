provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key

}

locals {
    env_type = "Dev" # cant have an apostrophe in the tag name
    env_name = "Jacobs TF Project"
}

# resource "aws_vpc" "jacobs_vpc_tf" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name        = "Jacobs VPC"
#     Environment = local.env_type
#   }
# }

# resource "aws_subnet" "jacobs_public_subnet" {
#   vpc_id     = aws_vpc.jacobs_vpc_tf.id
#   cidr_block = cidrsubnet(aws_vpc.jacobs_vpc_tf.cidr_block, 8, 1)
#   map_public_ip_on_launch = true

#   tags = {
#     Name        = "Jacobs Public Subnet"
#     Environment = local.env_type
#   }
# }

# resource "aws_subnet" "jacobs_private_subnet" {
#   vpc_id     = aws_vpc.jacobs_vpc_tf.id
#   cidr_block = cidrsubnet(aws_vpc.jacobs_vpc_tf.cidr_block, 8, 2)

#   tags = {
#     Name        = "Jacobs Private Subnet"
#     Environment = local.env_type
#   }
# }

# resource "aws_internet_gateway" "jacobs_gw" {
#   vpc_id = aws_vpc.jacobs_vpc_tf.id

#   tags = {
#     Name        = "Jacobs Gateway"
#     Environment = local.env_type
#   }
# }

# resource "aws_eip" "jacobs_eip" {
#   vpc = true
#   public_ipv4_pool = "amazon"
#   depends_on                = [aws_internet_gateway.jacobs_gw]
# }

# resource "aws_network_interface" "jacobs_network_interface" {
#   subnet_id       = aws_subnet.jacobs_public_subnet.id
#   # private_ips     = ["10.0.0.50"] # idk what to put here or how to make it automatic 

#   tags = {
#     Name        = "Jacobs Network Interface"
#     Environment = local.env_type
#   }
# }

# resource "aws_nat_gateway" "jacobs_nat_gw" {
#   allocation_id = aws_eip.jacobs_eip.id
#   subnet_id     = aws_subnet.jacobs_public_subnet.id
#   # network_interface_id = aws_network_interface.jacobs_network_interface.id

#   tags = {
#     Name        = "Jacobs NAT Gateway"
#     Environment = local.env_type
#   }

#   depends_on = [aws_internet_gateway.jacobs_gw]
# }
# # Elastic IP address [eipalloc-063efa619a6e80514] is already associated





# resource "aws_route_table" "jacobs_private_route_table" {
#   vpc_id = aws_vpc.jacobs_vpc_tf.id

#   route = [
#     {
#       cidr_block = "0.0.0.0/0"
#       nat_gateway_id = aws_nat_gateway.jacobs_nat_gw.id
#       carrier_gateway_id = ""
#       destination_prefix_list_id = ""
#       egress_only_gateway_id = ""
#       instance_id = ""
#       ipv6_cidr_block = ""
#       local_gateway_id = ""
#       gateway_id = ""
#       network_interface_id = ""
#       transit_gateway_id = ""
#       vpc_endpoint_id = ""
#       vpc_peering_connection_id = ""
#     }
#   ]

#   tags = {
#     Name        = "Jacobs Private Route Table"
#     Environment = local.env_type
#   }
# }

# resource "aws_route_table" "jacobs_public_route_table" {
#   vpc_id = aws_vpc.jacobs_vpc_tf.id

#   route = [
#     {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = aws_internet_gateway.jacobs_gw.id
#       carrier_gateway_id = ""
#       destination_prefix_list_id = ""
#       egress_only_gateway_id = ""
#       instance_id = ""
#       ipv6_cidr_block = ""
#       local_gateway_id = ""
#       nat_gateway_id = ""
#       network_interface_id = ""
#       transit_gateway_id = ""
#       vpc_endpoint_id = ""
#       vpc_peering_connection_id = ""
#     }
#   ]
#   tags = {
#     Name        = "Jacobs Public Route Table"
#     Environment = local.env_type
#   }
# }

# resource "aws_route_table_association" "jacobs_private_route" {
#   subnet_id      = aws_subnet.jacobs_private_subnet.id
#   route_table_id = aws_route_table.jacobs_private_route_table.id


# }

# resource "aws_route_table_association" "jacobs_public_route" {
#   subnet_id      = aws_subnet.jacobs_public_subnet.id
#   route_table_id = aws_route_table.jacobs_public_route_table.id

# }

# #### i had to manually verify my email in SES, dont think there's a programmatic way to validate yourself ???
# resource "aws_ses_email_identity" "jacobs_email" {
#   email = var.jacobs_email_address
# }


### aws lambda
# vpc = vpc
# subnet = private subnet
# security group = the tasks one
# lambda vpc role
# env variables
# 1	Klayers-python38-pandas	38	arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-pandas:38
# 2	Klayers-python38-lxml	6	arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-lxml:6
# 3	Klayers-python38-PyMySQL	4	arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-PyMySQL:4
# 4	Klayers-python38-SQLAlchemy	27	arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-SQLAlchemy:27
# 5	Klayers-python38-beautifulsoup4	10	arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-beautifulsoup4:10

resource "aws_lambda_function" "jacobs_lambda" {
  function_name = "Python Scraper"
  runtime = "python3.8"
  memory_size = 256
  timeout = 20
  role = aws_iam_role.jacobs_lambda_role.id
  handler = "lambda_function.lambda_handler"
  layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-pandas:38",
            "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-lxml:6",
            "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-PyMySQL:4",
            "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-SQLAlchemy:27",
            "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-beautifulsoup4:10"]


   environment {
    variables = {
      IP = "jacobs-rds-server.cdtvrcly92cn.us-east-1.rds.amazonaws.com"
      PORT = 3306
      RDS_DB = "jacob_db"
      RDS_PW = "jacobspass123"
      RDS_USER = "jacob1"
    }
  }

tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}
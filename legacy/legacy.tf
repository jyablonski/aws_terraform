#### gateways, route tables, subnets for lambda functionality

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

# resource "aws_subnet" "jacobs_public_subnet_2" {
#   vpc_id     = aws_vpc.jacobs_vpc_tf.id
#   cidr_block = cidrsubnet(aws_vpc.jacobs_vpc_tf.cidr_block, 8, 3)
#   map_public_ip_on_launch = true

#   tags = {
#     Name        = "Jacobs Public Subnet 2"
#     Environment = local.env_type
#   }
# }

# resource "aws_db_subnet_group" "jacobs_subnet_group" {
#   name = "jacobs-subnet-group"
#   subnet_ids = [aws_subnet.jacobs_public_subnet.id, aws_subnet.jacobs_public_subnet_2.id]

#   tags = {
#     Name        = local.env_name
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

#### i had to manually verify my email in SES, dont think there's a programmatic way to validate yourself ???
resource "aws_ses_email_identity" "jacobs_email" {
  email = var.jacobs_email_address
}

# ARNS for lambda role
# arn:aws:iam::aws:policy/AmazonSESFullAccess
# arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole

# i'm still figuring out assume_role_policy, has to do with the `TRUSTED_ENTITIES` part in IAM.  it's not some default policy, it points to what general area the iam role is.
# only 1 assume role per role
# 
resource "aws_iam_role" "jacobs_lambda_role" {
  name = "jacobs_lambda_role"
  description = "Role created for AWS ECS"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }]
}
EOF
}

# hardcoding aws managed policies seems to be fine / ok practice.
resource "aws_iam_role_policy_attachment" "jacobs_iam_role_update_lambda" {
  role       = aws_iam_role.jacobs_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "jacobs_iam_role_update_ses" {
  role       = aws_iam_role.jacobs_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

# resource "aws_lambda_function" "jacobs_lambda" {
#   function_name = "Python Scraper"
#   runtime = "python3.8"
#   memory_size = 256
#   timeout = 20
#   role = aws_iam_role.jacobs_lambda_role.arn
#   handler = "lambda_function2.lambda_handler"
#   filename = "C:/Users/Jacob/Documents/python_aws/lambda_function2.py"
#   s3_bucket = "https://jacobsbucket97.s3.amazonaws.com/"
#   s3_key = "lambda_function2.py"
#   layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-pandas:38",
#             "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-lxml:6",
#             "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-PyMySQL:4",
#             "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-SQLAlchemy:27",
#             "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-python38-beautifulsoup4:10"]
#    environment {
#     variables = {
#       IP = aws_db_instance.jacobs_rds_tf.address
#       PORT = aws_db_instance.jacobs_rds_tf.port
#       RDS_DB = "jacob_db"
#       RDS_PW = var.jacobs_rds_pw
#       RDS_USER = var.jacobs_rds_user
#     }
#   }

#     vpc_config {
#       security_group_ids = [aws_security_group.jacobs_task_security_group_tf.id]
#       subnet_ids = [aws_subnet.jacobs_private_subnet.id]
#     }

# tags = {
#     Name        = local.env_name
#     Environment = local.env_type
#   }
# }


##################
#                #
#     GRAFANA    # 
#                #
##################
# Worked, but cost $$ bc it makes requests for cloudwatch metrics every 60s or something

# data "aws_iam_policy_document" "jacobs_grafana_policy" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${local.grafana_account_id}:root"]
#     }

#     actions = ["sts:AssumeRole"]
#     condition {
#       test     = "StringEquals"
#       variable = "sts:ExternalId"
#       values   = [var.grafana_external_id]
#     }
#   }
# }

# resource "aws_iam_role" "grafana_labs_cloudwatch_integration" {
#   name        = "jacobs-grafana-role"
#   description = "Role used by Grafana CloudWatch Integration."

#   # Allow Grafana Labs' AWS account to assume this role.
#   assume_role_policy = data.aws_iam_policy_document.jacobs_grafana_policy.json

#   # This policy allows the role to discover metrics via tags and export them.
#   inline_policy {
#     name = "jacobs-grafana-role"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Effect = "Allow"
#           Action = [
#             "tag:GetResources",
#             "cloudwatch:GetMetricData",
#             "cloudwatch:GetMetricStatistics",
#             "cloudwatch:ListMetrics"
#           ]
#           Resource = "*"
#         }
#       ]
#     })
#   }
# }
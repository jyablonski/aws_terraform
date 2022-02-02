locals {
    env_name_dynamodb = "Jacobs Practice API"
    env_type_dynamodb = "Test" # cant have an apostrophe in the tag name
    lambda_name_dynamodb = "jacobs_lambda_dynamodb"
    account_id = data.aws_caller_identity.current.account_id
}

resource "aws_dynamodb_table" "jacobs_dynamodb_table" {
  name           = "product-inventory"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "productId"

    attribute {
    name = "productId"
    type = "S"
  }

    tags = {
    Name        = local.env_name_dynamodb
    Environment = local.env_type_dynamodb
  }
}

resource "aws_iam_role" "jacobs_lambda_dynamodb_role" {
  name = "jacobs_lambda_dynamodb_role"
  description = "Role created for AWS DynamoDB and API Prac"
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

resource "aws_iam_role_policy_attachment" "jacobs_lambda_dynamodb_role_attachment1" {
  role       = aws_iam_role.jacobs_lambda_dynamodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_dynamodb_role_attachment2" {
  role       = aws_iam_role.jacobs_lambda_dynamodb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_cloudwatch_log_group" "jacobs_lambda_dynamodb_logs" {
  name              = "/aws/lambda/${local.lambda_name_dynamodb}"
  retention_in_days = 14
}

data "archive_file" "lambda_dynamodb_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_dynamodb/"
  output_path = "${path.module}/myzip/lambda_dynamodb1.zip"
}

resource "aws_lambda_function" "jacobs_lambda_dynamodb_function" {
  filename                       = "${path.module}/myzip/lambda_dynamodb1.zip"
  function_name                  = local.lambda_name_dynamodb
  role                           = aws_iam_role.jacobs_lambda_dynamodb_role.arn
  handler                        = "main.lambda_handler"
  runtime                        = "python3.9"
  memory_size                    = 128
  timeout                        = 60

  tags = {
    Name        = local.env_name_dynamodb
    Environment = local.env_type_dynamodb
  }
}

resource "aws_api_gateway_rest_api" "jacobs_api_gateway" {
  name = "jacobs-serverless-api"

  tags = {
    Name        = local.env_name_dynamodb
    Environment = local.env_type_dynamodb
  }
}

# IF YOU CHANGE THIS THEN YOU HAVE TO REDEPLOY THE API GATEWAAAAAAAY
# principal aws means only aws services can get access via iam.  no ip whitelisting can be done with pricipal = aws
resource "aws_api_gateway_rest_api_policy" "jacobs_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.jacobs_api_gateway.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.jacobs_api_gateway.execution_arn}/*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.jacobs_api_gateway.execution_arn}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "104.153.228.249/32"
          ]
        }
      }
    }
  ]
}
EOF
}# arn:aws:execute-api:us-east-1:324816727452:fgvdktt1h3/*/GET/product

# RESOURCES
resource "aws_api_gateway_resource" "api_gateway_health" {
  parent_id   = aws_api_gateway_rest_api.jacobs_api_gateway.root_resource_id
  path_part   = "health"
  rest_api_id = aws_api_gateway_rest_api.jacobs_api_gateway.id
}

resource "aws_api_gateway_resource" "api_gateway_product" {
  parent_id   = aws_api_gateway_rest_api.jacobs_api_gateway.root_resource_id
  path_part   = "product"
  rest_api_id = aws_api_gateway_rest_api.jacobs_api_gateway.id
}

resource "aws_api_gateway_resource" "api_gateway_products" {
  parent_id   = aws_api_gateway_rest_api.jacobs_api_gateway.root_resource_id
  path_part   = "products"
  rest_api_id = aws_api_gateway_rest_api.jacobs_api_gateway.id
}

# METHOD IMPLEMENTATIONS
resource "aws_api_gateway_method" "api_gateway_health_get" {
  rest_api_id   = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_gateway_health_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_health.id
  http_method             = aws_api_gateway_method.api_gateway_health_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.jacobs_lambda_dynamodb_function.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_health" {
  statement_id  = "AllowExecutionFromAPIGatewayGetHealth"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_lambda_dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.jacobs_api_gateway.id}/*/${aws_api_gateway_method.api_gateway_health_get.http_method}${aws_api_gateway_resource.api_gateway_health.path}"
}

##
resource "aws_api_gateway_method" "api_gateway_product_get" {
  rest_api_id   = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_product.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_gateway_product_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_product.id
  http_method             = aws_api_gateway_method.api_gateway_product_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.jacobs_lambda_dynamodb_function.invoke_arn
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda_product" {
  statement_id  = "AllowExecutionFromAPIGatewayGetProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_lambda_dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.jacobs_api_gateway.id}/*/${aws_api_gateway_method.api_gateway_product_get.http_method}${aws_api_gateway_resource.api_gateway_product.path}"
}

##
resource "aws_api_gateway_method" "api_gateway_product_post" {
  rest_api_id   = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_product.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_gateway_product_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_product.id
  http_method             = aws_api_gateway_method.api_gateway_product_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.jacobs_lambda_dynamodb_function.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_product_post" {
  statement_id  = "AllowExecutionFromAPIGatewayPostProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_lambda_dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.jacobs_api_gateway.id}/*/${aws_api_gateway_method.api_gateway_product_post.http_method}${aws_api_gateway_resource.api_gateway_product.path}"
}

##
resource "aws_api_gateway_method" "api_gateway_product_patch" {
  rest_api_id   = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_product.id
  http_method   = "PATCH"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_gateway_product_patch_integration" {
  rest_api_id             = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_product.id
  http_method             = aws_api_gateway_method.api_gateway_product_patch.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.jacobs_lambda_dynamodb_function.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_product_patch" {
  statement_id  = "AllowExecutionFromAPIGatewayPatchProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_lambda_dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.jacobs_api_gateway.id}/*/${aws_api_gateway_method.api_gateway_product_patch.http_method}${aws_api_gateway_resource.api_gateway_product.path}"
}

##
resource "aws_api_gateway_method" "api_gateway_product_delete" {
  rest_api_id   = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_product.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_gateway_product_delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_product.id
  http_method             = aws_api_gateway_method.api_gateway_product_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.jacobs_lambda_dynamodb_function.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_product_delete" {
  statement_id  = "AllowExecutionFromAPIGatewayDeleteProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_lambda_dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.jacobs_api_gateway.id}/*/${aws_api_gateway_method.api_gateway_product_delete.http_method}${aws_api_gateway_resource.api_gateway_product.path}"
}

##
resource "aws_api_gateway_method" "api_gateway_products_get" {
  rest_api_id   = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_products.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_gateway_products_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.jacobs_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_products.id
  http_method             = aws_api_gateway_method.api_gateway_products_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.jacobs_lambda_dynamodb_function.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_products_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGetProducts"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jacobs_lambda_dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.jacobs_api_gateway.id}/*/${aws_api_gateway_method.api_gateway_products_get.http_method}${aws_api_gateway_resource.api_gateway_products.path}"
}

# deployment - leaving it off for now just in case
resource "aws_api_gateway_deployment" "jacobs_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.jacobs_api_gateway.id
  description = "Jacobs Practice API Gateway"

}

resource "aws_api_gateway_stage" "jacobs_deployment_stage" {
  deployment_id = aws_api_gateway_deployment.jacobs_api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.jacobs_api_gateway.id
  stage_name    = "Dev"
}

# General idea is you create dynamodb table with a primary key attribute (productId, String)
# then create api gateway and its endpoints (resources), and then methods on those endpoints (get, put, post, patch, delete etc).
# the lambda function then acts upon those methods to do CRUD operations (GET -> send productId info back, DELETE -> delete something).
# all of that logic is encapsulated in the lambda function
# go to postman and test there
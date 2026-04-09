locals {
  env_name_es     = "Jacobs Practice ES Cluster"
  env_type_es     = "Test" # cant have an apostrophe in the tag name
  terraform_es    = true
  es_cluster_name = "jacobs-opensearch-cluster"
  es_logs_name    = "jacobs-es-cluster-logs"
}

resource "aws_iam_role" "jacobs_lambda_es_role" {
  name               = "jacobs_lambda_es_role"
  description        = "Role created for AWS Lambda ES Logs"
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

resource "aws_iam_policy" "lambda_es_policy" {
  name        = "lambda-es-policy"
  description = "A test policy for lambda to write cloudwatch logs to es"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "es:*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${local.es_cluster_name}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_es_role_attachment1" {
  role       = aws_iam_role.jacobs_lambda_es_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "jacobs_lambda_es_role_attachment2" {
  role       = aws_iam_role.jacobs_lambda_es_role.name
  policy_arn = aws_iam_policy.lambda_es_policy.arn
}

resource "aws_cloudwatch_log_group" "jacobs_es_cluster_logs" {
  name              = local.es_logs_name
  retention_in_days = 7
}
data "aws_iam_policy_document" "jacobs_es_cluster_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = ["arn:aws:logs:*"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "jacobs_es_cluster_logs" {
  policy_document = data.aws_iam_policy_document.jacobs_es_cluster_logs.json
  policy_name     = "jacobs_es_cluster_logs"
}

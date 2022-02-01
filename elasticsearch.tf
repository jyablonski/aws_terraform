locals {
    env_name_es = "Jacobs Practice ES Cluster"
    env_type_es = "Test" # cant have an apostrophe in the tag name
    terraform_es = true
    es_cluster_name = "jacobs-opensearch-cluster"
    es_logs_name = "jacobs-es-cluster-logs"
}

resource "aws_cloudwatch_log_group" "jacobs_es_cluster_logs" {
  name              = local.es_logs_name
  retention_in_days = 7
}

# need this so ES can operate in my VPC
# resource "aws_iam_service_linked_role" "es_access" {
#   aws_service_name = "es.amazonaws.com"
# }

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

resource "aws_elasticsearch_domain" "jacobs_opensearch_cluster" {
  domain_name           = local.es_cluster_name
  elasticsearch_version = "OpenSearch_1.1"

  cluster_config {
    instance_type            = "t2.small.elasticsearch"
    instance_count           = 1
    dedicated_master_enabled = false
    zone_awareness_enabled   = false
  }

  ebs_options {
      ebs_enabled = true
      volume_size = 10
      volume_type = "gp2"
  }

#   vpc_options {
#     subnet_ids = [
#         aws_subnet.jacobs_public_subnet.id,
#     ]

#     security_group_ids = [aws_security_group.jacobs_task_security_group_tf.id]
#   }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.jacobs_es_cluster_logs.arn
    log_type = "INDEX_SLOW_LOGS"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${local.es_cluster_name}/*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${local.es_cluster_name}/*",
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
CONFIG

  tags = {
    Name        = local.env_name_es
    Environment = local.env_type_es
    Terraform   = local.terraform_es
  }

#   depends_on = [aws_iam_service_linked_role.es_access]
}
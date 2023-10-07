module "github_iam_ecr_test" {
  source              = "./modules/iam_github"
  iam_role_name       = "first-ecr-test"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/kafka_faker_stream"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.jacobs_repo.name}"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        }
    ]
}
EOF

}

module "python_docker" {
  source              = "./modules/iam_github"
  iam_role_name       = "python-docker"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/python_docker"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.jacobs_repo.name}"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        }
    ]
}
EOF

}

module "dbt_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = "dbt_github"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/nba_elt_dbt"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.jacobs_repo.name}"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${module.dbt_s3_ci_module.s3_bucket_arn}",
                "${module.dbt_s3_ci_module.s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF

}

module "ml_pipeline_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = "ml_pipeline_github"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/nba_elt_mlflow"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.jacobs_repo.name}"
        },
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        }
    ]
}
EOF

}

module "rest_api_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = "rest_api_github"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/nba_elt_rest_api"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_tf_dev.bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_tf_dev.bucket}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:UpdateFunctionCode"
            ],
            "Resource": [
                "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.jacobs_rest_api_lambda_function.id}"
            ]
        }
    ]
}
EOF

}

module "website_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = "website_github"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/jyablonski.github.io"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_tf_dev.bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_tf_dev.bucket}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:UpdateFunctionCode"
            ],
            "Resource": [
                "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.jacobs_rest_api_lambda_function.id}"
            ]
        }
    ]
}
EOF

}

module "kimball_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = "dbt_kimball"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/jyablonski_kimball_example"
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${module.dbt_s3_ci_module.s3_bucket_arn}",
                "${module.dbt_s3_ci_module.s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF

}
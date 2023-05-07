resource "aws_iam_openid_connect_provider" "github_provider" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# ℹ️Note: When GitHub inevitably rotates the certificate for this service, the thumbprint_list value will need to be updated.
# rest of this below is outdated as of 2023-04-13 - use the fkn module 
data "aws_iam_policy_document" "github_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:jyablonski/kafka_faker_stream:*"]
    }
  }
}

resource "aws_iam_role" "github_oidc_role" {
  name               = "jacobs-github-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.github_policy.json
}

resource "aws_iam_policy" "github_oidc_policy" {
  name        = "jacobs_github_oidc_policy"
  description = "A Policy for GitHub Actions to write to S3 Bucket using OIDC Credentials"

  policy = <<EOF
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
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_github_s3_website_user_attachment" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_oidc_policy.arn
}

## rest api github actions role
data "aws_iam_policy_document" "rest_api_github_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:jyablonski/nba_elt_rest_api:*"]
    }
  }
}

resource "aws_iam_role" "rest_api_github_oidc_role" {
  name               = "jacobs-rest-api-github-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.rest_api_github_policy.json
}

resource "aws_iam_policy" "rest_api_github_oidc_policy" {
  name        = "jacobs_rest_api_github_oidc_policy"
  description = "A Policy for GitHub Actions to write to S3 Bucket using OIDC Credentials"

  policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "jacobs_rest_api_github_user_attachment" {
  role       = aws_iam_role.rest_api_github_oidc_role.name
  policy_arn = aws_iam_policy.rest_api_github_oidc_policy.arn
}

# GraphQL Role
data "aws_iam_policy_document" "graphql_github_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:jyablonski/graphql_praq:*"]
    }
  }
}

resource "aws_iam_role" "graphql_github_oidc_role" {
  name               = "jacobs-graphql-github-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.graphql_github_policy.json
}

resource "aws_iam_policy" "graphql_github_oidc_policy" {
  name        = "jacobs_graphql_github_oidc_policy"
  description = "A Policy for GitHub Actions to write to S3 Bucket using OIDC Credentials"

  policy = <<EOF
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
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_graphql_github_user_attachment" {
  role       = aws_iam_role.graphql_github_oidc_role.name
  policy_arn = aws_iam_policy.graphql_github_oidc_policy.arn
}

## Website Role
# GraphQL Role
data "aws_iam_policy_document" "website_github_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:jyablonski/jyablonski.github.io:*"]
    }
  }
}

resource "aws_iam_role" "website_github_oidc_role" {
  name               = "jacobs-website-github-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.website_github_policy.json
}

resource "aws_iam_policy" "website_github_oidc_policy" {
  name        = "jacobs_website_github_oidc_policy"
  description = "A Policy for GitHub Actions to write to S3 Bucket using OIDC Credentials"

  policy = <<EOF
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
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_website.bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.jacobs_bucket_website.bucket}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jacobs_website_github_user_attachment" {
  role       = aws_iam_role.website_github_oidc_role.name
  policy_arn = aws_iam_policy.website_github_oidc_policy.arn
}
locals {
  website_v2_bucket_name = "jyablonski-site"
  website_v2_origin_id   = "jyablonski-site-origin"
  website_v2_repo        = "jyablonski/site"
}

resource "aws_s3_bucket" "website_v2" {
  bucket = local.website_v2_bucket_name

  tags = {
    Name        = local.website_v2_bucket_name
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "website_v2" {
  bucket = aws_s3_bucket.website_v2.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website_v2" {
  bucket = aws_s3_bucket.website_v2.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "website_v2" {
  bucket = aws_s3_bucket.website_v2.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "website_v2" {
  bucket = aws_s3_bucket.website_v2.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "website_v2" {
  bucket = aws_s3_bucket.website_v2.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "website_v2" {
  name                              = "jyablonski-site-origin-access-control"
  description                       = "Origin access control for the jyablonski/site static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "website_v2_uri_rewrite" {
  name    = "jyablonski-site-uri-rewrite"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite trailing-slash static site paths to index.html objects"
  publish = true
  code    = <<EOF
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri.endsWith('/')) {
    request.uri += 'index.html';
  } else if (!uri.includes('.')) {
    request.uri += '/index.html';
  }

  return request;
}
EOF
}

resource "aws_cloudfront_distribution" "website_v2" {
  origin {
    domain_name              = aws_s3_bucket.website_v2.bucket_regional_domain_name
    origin_id                = local.website_v2_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.website_v2.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "jyablonski Site V2 Distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_200"
  aliases             = [local.website_domain, "www.${local.website_domain}"]

  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.website_v2_origin_id
    compress         = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.website_v2_uri_rewrite.arn
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/_astro/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.website_v2_origin_id
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 31536000
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "jyablonski97-dev.s3.amazonaws.com"
    prefix          = "website-v2"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.jacobs_website_cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = "production"
  }

  lifecycle {
    ignore_changes = [
      origin,
    ]
  }

  depends_on = [
    aws_cloudfront_distribution.jacobs_website_s3_distribution,
  ]
}

data "aws_iam_policy_document" "website_v2_github" {
  statement {
    sid    = "S3DeployList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.website_v2.arn,
    ]
  }

  statement {
    sid    = "S3DeployObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.website_v2.arn}/*",
    ]
  }

  statement {
    sid    = "CloudFrontInvalidate"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
    ]
    resources = [
      aws_cloudfront_distribution.website_v2.arn,
    ]
  }
}

module "website_v2_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = "jyablonski-site-github"
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = local.website_v2_repo
  github_sub          = "repo:${local.website_v2_repo}:ref:refs/heads/main"
  iam_role_policy     = data.aws_iam_policy_document.website_v2_github.json
}

data "aws_iam_policy_document" "website_v2_bucket" {
  statement {
    sid    = "AllowGitHubDeployRole"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        module.website_v2_github_cicd.iam_role_arn,
      ]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.website_v2.arn,
    ]
  }

  statement {
    sid    = "AllowGitHubDeployObjects"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        module.website_v2_github_cicd.iam_role_arn,
      ]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.website_v2.arn}/*",
    ]
  }

  statement {
    sid    = "AllowCloudFrontReadAccess"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.website_v2.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.website_v2.arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "website_v2" {
  bucket = aws_s3_bucket.website_v2.id
  policy = data.aws_iam_policy_document.website_v2_bucket.json
}

output "website_v2_bucket_name" {
  value = aws_s3_bucket.website_v2.id
}

output "website_v2_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website_v2.id
}

output "website_v2_cloudfront_domain_name" {
  value = aws_cloudfront_distribution.website_v2.domain_name
}

output "website_v2_github_role_arn" {
  value = module.website_v2_github_cicd.iam_role_arn
}

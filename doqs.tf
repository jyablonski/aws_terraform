locals {
  doqs_bucket    = "jyablonski-doqs"
  doqs_iam_role  = "doqs-github"
  doqs_origin_id = "jyablonski-doqs-origin"
}


resource "aws_s3_bucket" "doqs_bucket" {
  bucket = local.doqs_bucket

  tags = {
    Environment = local.env_type
  }

}

resource "aws_s3_bucket_website_configuration" "doqs_website_config" {
  bucket = aws_s3_bucket.doqs_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

  routing_rule {
    condition {
      http_error_code_returned_equals = "404"
    }
    redirect {
      host_name               = "www.doqs.jyablonski.dev"
      protocol                = "https"
      replace_key_prefix_with = "#!/"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "doqs_ownership" {
  bucket = aws_s3_bucket.doqs_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Block Public Access to S3 Bucket (we will use CloudFront for serving)
resource "aws_s3_bucket_public_access_block" "doqs_public_access_block" {
  bucket = aws_s3_bucket.doqs_bucket.id

  block_public_acls   = false
  block_public_policy = false
}


# CloudFront Distribution
resource "aws_cloudfront_distribution" "doqs_distribution" {
  aliases     = ["doqs.${local.website_domain}"]
  price_class = "PriceClass_200"


  origin {
    domain_name = aws_s3_bucket_website_configuration.doqs_website_config.website_endpoint
    origin_id   = local.doqs_origin_id

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Doqs Distribution"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.doqs_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.jacobs_website_cert.arn
    ssl_support_method  = "sni-only"
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
    prefix          = "doqs"
  }

  tags = {
    Environment = "production"
  }

}

# S3 Bucket Policy to allow CloudFront to serve the content
resource "aws_s3_object" "doqs_policy" {
  bucket = aws_s3_bucket.doqs_bucket.id
  key    = "doqs-static-web-policy.json"
  acl    = "private"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${local.doqs_bucket}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "CloudFront"
          }
        }
      }
    ]
  })
}

# CloudFront Origin Access Identity (OAI) for secure S3 access
resource "aws_s3_bucket_policy" "doqs_bucket_policy" {
  bucket = aws_s3_bucket.doqs_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Principal = {
          "AWS" : "${module.doqs_github_cicd.iam_role_arn}"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.doqs_bucket.id}/*"
      },
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Principal = {
          "AWS" : "${module.doqs_github_cicd.iam_role_arn}"
        }
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.doqs_bucket.id}"
      },
      {
        Sid       = "AllowReadAccess"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.doqs_bucket.id}/*"
      }
    ]
  })
}



module "doqs_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = local.doqs_iam_role
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = "jyablonski/doqs"
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
                "arn:aws:s3:::${aws_s3_bucket.doqs_bucket.id}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.doqs_bucket.id}"
            ]
        }
    ]
}
EOF

}

resource "aws_route53_record" "doqs_route53_record" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "doqs.${local.website_domain}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.doqs_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.doqs_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

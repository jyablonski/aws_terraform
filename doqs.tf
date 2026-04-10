locals {
  doqs_bucket    = "jyablonski-doqs"
  doqs_iam_role  = "doqs-github"
  doqs_origin_id = "jyablonski-doqs-origin"
}

# cant use Cloudfront OAC w/ private S3 Bucket, it requires a custom lambda edge function to run
# on literally every request to turn files like `services/docs/dbt` into `services/docs/dbt/index.html`
resource "aws_s3_bucket" "doqs_bucket" {
  bucket = local.doqs_bucket
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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "doqs_origin_access_control" {
  name                              = "doqs-origin-access-control"
  description                       = "Origin access control for the Doqs CloudFront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "doqs_uri_rewrite" {
  name    = "doqs-uri-rewrite"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite extensionless Doqs paths to index.html objects"
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

# CloudFront Distribution
resource "aws_cloudfront_distribution" "doqs_distribution" {
  aliases     = ["doqs.${local.website_domain}"]
  price_class = "PriceClass_200"


  origin {
    domain_name              = aws_s3_bucket.doqs_bucket.bucket_regional_domain_name
    origin_id                = local.doqs_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.doqs_origin_access_control.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Doqs Distribution"
  default_root_object = "index.html"

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
    target_origin_id = local.doqs_origin_id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.doqs_uri_rewrite.arn
    }

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
        Sid    = "AllowCloudFrontReadAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = [
          "s3:GetObject"
        ],
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.doqs_distribution.arn
          }
        },
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

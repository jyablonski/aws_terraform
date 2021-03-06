locals {
  s3_origin_id   = "jacobs_s3_website_origin"
  website_domain = "jyablonski.dev"
}


resource "aws_iam_user" "jacobs_github_s3_website_user" {
  name = "jacobs_github_s3_website_user"

}

resource "aws_iam_policy" "github_s3_website_policy" {
  name        = "jacobsbucket97_github_s3_website_policy"
  description = "A Policy for GitHub Actions to write to S3 Bucket for Website"

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

resource "aws_iam_user_policy_attachment" "jacobs_github_s3_website_user_attachment" {
  user       = aws_iam_user.jacobs_github_s3_website_user.name
  policy_arn = aws_iam_policy.github_s3_website_policy.arn
}


resource "aws_s3_bucket" "jacobs_bucket_website" {
  bucket = "www.jyablonski.dev"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket_acl" "jacobs_bucket_website_acl" {
  bucket = aws_s3_bucket.jacobs_bucket_website.id

  acl = "public-read"
}

resource "aws_s3_bucket" "jacobs_bucket_website_link" {
  bucket = local.website_domain

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket_acl" "jacobs_bucket_website_link_acl" {
  bucket = aws_s3_bucket.jacobs_bucket_website_link.id

  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "jacobs_bucket_website_config" {
  bucket = aws_s3_bucket.jacobs_bucket_website.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  routing_rule {
    condition {
      http_error_code_returned_equals = "404"
    }
    redirect {
      host_name               = "www.jyablonski.dev"
      protocol                = "https"
      replace_key_prefix_with = "#!/"
    }
  }
}

resource "aws_s3_bucket_policy" "jacobs_bucket_website_policy" {
  bucket = aws_s3_bucket.jacobs_bucket_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"],
        Resource = [
          "${aws_s3_bucket.jacobs_bucket_website.arn}/*",
        ]
      },
    ]
  })
}

# probably needs to just be jyablonski.dev in order to properly route www.jyablonski.dev and jyablonski.dev to www.
resource "aws_route53_zone" "jacobs_website_zone" {
  name = local.website_domain

  tags = {
    Environment = "dev"
  }
}


resource "aws_route53_record" "jacobs_website_route53_record" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = ""
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.jacobs_website_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.jacobs_website_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "jacobs_website_route53_record_www" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "www.${local.website_domain}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.jacobs_website_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.jacobs_website_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "jacobs_website_route53_record_cert" {
  for_each = {
    for dvo in aws_acm_certificate.jacobs_website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.jacobs_website_zone.zone_id
}

resource "aws_acm_certificate" "jacobs_website_cert" {
  domain_name               = local.website_domain
  subject_alternative_names = ["www.${local.website_domain}"]
  validation_method         = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_acm_certificate_validation" "jacobs_website_cert_verifiy" {
#   certificate_arn         = aws_acm_certificate.jacobs_website_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.jacobs_website_route53_record_cert : record.fqdn]
# }

resource "aws_cloudfront_origin_access_identity" "jacobs_website_origin_identity" {
  comment = "Jacobs Website Origin Identity"
}

resource "aws_cloudfront_distribution" "jacobs_website_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.jacobs_bucket_website.website_endpoint
    origin_id   = local.s3_origin_id

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
  comment         = "Some comment"
  # default_root_object = "index.html"

  # custom_error_response {
  #   error_code         = 404
  #   response_code      = 200
  #   response_page_path = "/index.html"
  # }

  logging_config {
    include_cookies = false
    bucket          = "jacobsbucket97-dev.s3.amazonaws.com"
    prefix          = "website"
  }

  aliases = [local.website_domain, "www.${local.website_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

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

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.jacobs_website_cert.arn
    ssl_support_method  = "sni-only"
  }
}
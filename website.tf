locals {
  s3_origin_id   = "jacobs_s3_website_origin"
  api_origin_id  = "jacobs_api_website_origin"
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
  bucket = "www.jyablonski2.dev"

  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket_public_access_block" "jacobs_domain_bucket_access_block" {
  bucket = aws_s3_bucket.jacobs_bucket_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "jacobs_domain_bucket_ownership" {
  depends_on = [aws_s3_bucket_public_access_block.jacobs_domain_bucket_access_block]

  bucket = aws_s3_bucket.jacobs_bucket_website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_acl" "jacobs_bucket_website_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.jacobs_domain_bucket_ownership]
  bucket     = aws_s3_bucket.jacobs_bucket_website.id

  acl = "public-read"
}

resource "aws_s3_bucket" "jacobs_bucket_website_link" {
  bucket = "jyablonski2.dev"
  tags = {
    Name        = local.env_name
    Environment = local.env_type
  }
}

resource "aws_s3_bucket_public_access_block" "jacobs_domainless_bucket_access_block" {
  bucket = aws_s3_bucket.jacobs_bucket_website_link.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "jacobs_domainless_bucket_ownership" {
  depends_on = [aws_s3_bucket_public_access_block.jacobs_domainless_bucket_access_block]

  bucket = aws_s3_bucket.jacobs_bucket_website_link.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "jacobs_bucket_website_link_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.jacobs_domainless_bucket_ownership]
  bucket     = aws_s3_bucket.jacobs_bucket_website_link.id

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

# resource "aws_route53_record" "jacobs_website_route53_record_graphql" {
#   zone_id = aws_route53_zone.jacobs_website_zone.zone_id
#   name    = "graphql.${local.website_domain}"
#   type    = "A"
#   alias {
#     name                   = aws_lb.graphql_alb.dns_name
#     zone_id                = aws_lb.graphql_alb.zone_id
#     evaluate_target_health = false
#   }
# }

resource "aws_route53_record" "jacobs_website_route53_record_shiny" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "nbadashboard.${local.website_domain}"
  type    = "A"
  alias {
    name                   = aws_lb.shiny_alb.dns_name
    zone_id                = aws_lb.shiny_alb.zone_id
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
    # https://github.com/hashicorp/terraform-provider-aws/issues/16913
    # Skips the validation record if the certificate contains a wildcard for the same domain. Needed because AWS returns the same validation records for the wildcard domain.
    if contains(concat([aws_acm_certificate.jacobs_website_cert.domain_name], tolist(aws_acm_certificate.jacobs_website_cert.subject_alternative_names)), "*.${dvo.domain_name}") == false
  }


  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.jacobs_website_zone.zone_id
}

# change subject alt names to *. instead of www.
#wildcard can protect *.example.com so like app.example.com and www.example.com, but not www.app.example.com

resource "aws_acm_certificate" "jacobs_website_cert" {
  domain_name               = local.website_domain
  subject_alternative_names = ["*.${local.website_domain}"]
  validation_method         = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "jacobs_website_cert_verifiy" {
  certificate_arn         = aws_acm_certificate.jacobs_website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.jacobs_website_route53_record_cert : record.fqdn]
}

resource "aws_cloudfront_origin_access_identity" "jacobs_website_origin_identity" {
  comment = "Jacobs Website Origin Identity"
}

resource "aws_cloudfront_distribution" "jacobs_website_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.jacobs_bucket_website_config.website_endpoint
    # domain_name = aws_s3_bucket.jacobs_bucket_website.website_endpoint
    origin_id = local.s3_origin_id

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
    bucket          = "jyablonski97-dev.s3.amazonaws.com"
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

resource "aws_cloudfront_distribution" "jacobs_website_api_distribution" {
  origin {
    # can't have the https://
    domain_name = "${aws_lambda_function_url.jacobs_rest_api_lambda_function_url.url_id}.lambda-url.us-east-1.on.aws"
    origin_id   = local.api_origin_id

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }

  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "API Distribution"
  # default_root_object = "index.html"

  # custom_error_response {
  #   error_code         = 404
  #   response_code      = 200
  #   response_page_path = "/index.html"
  # }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.jacobs_bucket_tf_dev.bucket_domain_name
    prefix          = "website"
  }

  aliases = ["api.${local.website_domain}"]


  ordered_cache_behavior {
    path_pattern             = "/bets"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/login"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/past_bets"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/admin"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/admin/incidents"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/admin/incidents/create"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/admin/feature_flags"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/admin/feature_flags/create"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"] # have to be here or it fails
    target_origin_id         = local.api_origin_id
    cache_policy_id          = aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.origin_request_policy.id
    viewer_protocol_policy   = "redirect-to-https"
    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.api_origin_id

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
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.api_origin_id

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
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.api_origin_id

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

resource "aws_route53_record" "jacobs_website_route53_record_api" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "api.${local.website_domain}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.jacobs_website_api_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.jacobs_website_api_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_cache_policy" "caching_disabled" {
  name        = "jyablonski-caching-disabled-policy"
  comment     = "Policy which mimics AWS CachingDisabled Policy"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"

    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "origin_request_policy" {
  name    = "jyablonski-caching-origin-request-policy"
  comment = "Policy which mimics AWS Managed-AllViewerExceptHostHeader Policy"
  cookies_config {
    cookie_behavior = "all"

  }
  headers_config {
    header_behavior = "allExcept"
    headers {
      items = ["host"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}
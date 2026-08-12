# DNS for jyablonski.dev, migrated here from a Route53 hosted zone (2026-08) to drop the
# $0.50/mo zone fee. The domain is registered at Squarespace; its nameservers must point at
# the cloudflare_zone_name_servers output for this zone to be live.

resource "cloudflare_zone" "jacobs_website" {
  account = {
    id = var.cloudflare_account_id
  }
  name = local.website_domain
  type = "full"
}

# CloudFront-backed records stay DNS-only (proxied = false) so Cloudflare's CDN doesn't
# stack in front of CloudFront. Cloudflare flattens the apex CNAME automatically.
# ttl = 1 is Cloudflare's "automatic" TTL sentinel.
resource "cloudflare_dns_record" "website_apex" {
  zone_id = cloudflare_zone.jacobs_website.id
  name    = local.website_domain
  type    = "CNAME"
  content = aws_cloudfront_distribution.website_v2.domain_name
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "website_www" {
  zone_id = cloudflare_zone.jacobs_website.id
  name    = "www.${local.website_domain}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.website_v2.domain_name
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "website_api" {
  zone_id = cloudflare_zone.jacobs_website.id
  name    = "api.${local.website_domain}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.jacobs_website_api_distribution.domain_name
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "doqs" {
  zone_id = cloudflare_zone.jacobs_website.id
  name    = "doqs.${local.website_domain}"
  type    = "CNAME"
  content = aws_cloudfront_distribution.doqs_distribution.domain_name
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "dashboard" {
  zone_id = cloudflare_zone.jacobs_website.id
  name    = "nbadashboard.${local.website_domain}"
  type    = "A"
  content = local.dashboard_vm_ip
  ttl     = local.dashboard_dns_ttl
  proxied = false
}

# DNS-only: Cloudflare's proxy buffers responses, which breaks SSE streaming used by MCP.
resource "cloudflare_dns_record" "mcp" {
  zone_id = cloudflare_zone.jacobs_website.id
  name    = "mcp.${local.website_domain}"
  type    = "A"
  content = local.dashboard_vm_ip
  ttl     = local.dashboard_dns_ttl
  proxied = false
}

# ACM auto-renewal depends on this validation CNAME staying resolvable.
# The filter skips the wildcard SAN's entry: AWS returns the same validation record
# for jyablonski.dev and *.jyablonski.dev (hashicorp/terraform-provider-aws#16913).
resource "cloudflare_dns_record" "website_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.jacobs_website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
    if contains(concat([aws_acm_certificate.jacobs_website_cert.domain_name], tolist(aws_acm_certificate.jacobs_website_cert.subject_alternative_names)), "*.${dvo.domain_name}") == false
  }

  zone_id = cloudflare_zone.jacobs_website.id
  name    = trimsuffix(each.value.name, ".")
  type    = each.value.type
  content = trimsuffix(each.value.record, ".")
  ttl     = 60
  proxied = false
}

output "cloudflare_zone_name_servers" {
  description = "The domain's nameservers — must match what's configured at the Squarespace registrar."
  value       = cloudflare_zone.jacobs_website.name_servers
}

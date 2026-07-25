locals {
  dashboard_vm_ip   = "34.83.137.138"
  dashboard_dns_ttl = 300
}

resource "aws_route53_record" "route53_dashboard_record" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "nbadashboard.jyablonski.dev"
  type    = "A"
  ttl     = local.dashboard_dns_ttl
  records = [local.dashboard_vm_ip]
}

resource "aws_route53_record" "route53_mcp_record" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "mcp.jyablonski.dev"
  type    = "A"
  ttl     = local.dashboard_dns_ttl
  records = [local.dashboard_vm_ip]
}

resource "aws_route53_record" "route53_dashboard_record" {
  zone_id = aws_route53_zone.jacobs_website_zone.zone_id
  name    = "nbadashboard.jyablonski.dev"
  type    = "A"
  ttl     = 300
  records = ["34.83.137.138"]
}

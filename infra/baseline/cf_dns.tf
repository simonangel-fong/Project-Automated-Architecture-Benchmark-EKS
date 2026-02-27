# baseline/cf_dns.tf

data "aws_lb" "alb" {
  name = "${var.project_name}-${var.arch}"
}

# ########################################
# Cloudflare
# ########################################
resource "cloudflare_record" "dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = local.dns_record
  # content = aws_cloudfront_distribution.cdn.domain_name
  content = data.aws_lb.alb.dns_name
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

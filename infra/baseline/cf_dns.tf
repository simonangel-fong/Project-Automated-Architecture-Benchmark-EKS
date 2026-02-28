# # baseline/cf_dns.tf

# locals {
#   alb_hostname = try(
#     kubernetes_ingress_v1.nginx_alb.status[0].load_balancer[0].ingress[0].hostname,
#     null
#   )
# }

# resource "cloudflare_record" "dns_record" {
#   count   = local.alb_hostname == null ? 0 : 1
#   zone_id = var.cloudflare_zone_id
#   name    = local.dns_record
#   content = local.alb_hostname
#   type    = "CNAME"
#   ttl     = 1
#   proxied = true
# }

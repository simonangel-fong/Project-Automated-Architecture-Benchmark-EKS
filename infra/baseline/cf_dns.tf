# # baseline/cf_dns.tf

# locals {
#   alb_dns = try(kubernetes_ingress_v1.nginx_alb.status[0].load_balancer[0].ingress[0].hostname, null)
# }

# resource "cloudflare_record" "dns_record" {
#   for_each = local.alb_dns == null ? {} : { "this" = local.alb_dns }

#   zone_id = var.cloudflare_zone_id
#   name    = local.dns_record
#   content = each.value
#   type    = "CNAME"
#   ttl     = 1
#   proxied = true
# }

# # baseline/aws_eks_dns.tf

# locals {
#   dns_helm_release        = "external-dns"
#   dns_helm_namespace      = "external-dns"
#   dns_helm_repository     = "https://kubernetes-sigs.github.io/external-dns/"
#   dns_helm_chart          = "external-dns"
#   dns_helm_version        = "1.19.0"
#   dns_helm_serviceaccount = "external-dns"
# }

# # ###################################
# # Kubernetes Resources
# # ###################################
# resource "kubernetes_namespace_v1" "dns" {
#   metadata {
#     name = local.dns_helm_namespace
#   }
# }

# resource "kubernetes_secret_v1" "dns_cloudflare" {
#   metadata {
#     name      = "external-dns-cloudflare"
#     namespace = kubernetes_namespace_v1.dns.metadata[0].name
#   }

#   type = "Opaque"

#   data = {
#     api-token = var.cloudflare_api_token
#   }
# }

# resource "kubernetes_service_account_v1" "dns" {
#   metadata {
#     name      = "external-dns"
#     namespace = kubernetes_namespace_v1.dns.metadata[0].name
#     labels = {
#       "app.kubernetes.io/name" = "external-dns"
#     }
#   }
# }

# # ###################################
# # Helm Package
# # ###################################
# resource "helm_release" "dns" {
#   name       = local.dns_helm_release
#   namespace  = kubernetes_namespace_v1.dns.metadata[0].name
#   repository = local.dns_helm_repository
#   chart      = local.dns_helm_chart
#   version    = local.dns_helm_version

#   wait             = true
#   timeout          = 600
#   create_namespace = false

#   set = [
#     { name = "sources[0]", value = "ingress" },
#     { name = "provider", value = "cloudflare" },

#     { name = "domainFilters[0]", value = var.domain_name },

#     { name = "policy", value = "sync" },
#     { name = "registry", value = "txt" },

#     { name = "serviceAccount.create", value = "false" },
#     { name = "serviceAccount.name", value = kubernetes_service_account_v1.dns.metadata[0].name },

#     { name = "env[0].name", value = "CF_API_TOKEN" },
#     { name = "env[0].valueFrom.secretKeyRef.name", value = kubernetes_secret_v1.dns_cloudflare.metadata[0].name },
#     { name = "env[0].valueFrom.secretKeyRef.key", value = "api-token" }
#   ]

#   depends_on = [
#     kubernetes_namespace_v1.dns,
#     kubernetes_secret_v1.dns_cloudflare,
#     kubernetes_service_account_v1.dns
#   ]
# }

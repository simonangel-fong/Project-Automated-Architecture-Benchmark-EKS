# # baseline/aws_eks_dns.tf

# locals {
#   namespace_dns = "external-dns"
# }

# # ###################################
# # Kubernetes Resources
# # ###################################
# resource "kubernetes_namespace_v1" "external_dns" {
#   metadata {
#     name = local.namespace_dns
#   }
# }

# resource "kubernetes_secret_v1" "external_dns_cloudflare" {
#   metadata {
#     name      = "external-dns-cloudflare"
#     namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
#   }

#   type = "Opaque"

#   data = {
#     api-token = var.cloudflare_api_token
#   }
# }

# resource "kubernetes_service_account_v1" "external_dns" {
#   metadata {
#     name      = "external-dns"
#     namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
#     labels = {
#       "app.kubernetes.io/name" = "external-dns"
#     }
#   }
# }

# # # # ###################################
# # # # Helm Package
# # # # ###################################
# # # resource "helm_release" "external_dns" {
# # #   name       = "external-dns"
# # #   namespace  = kubernetes_namespace_v1.external_dns.metadata[0].name
# # #   repository = "https://kubernetes-sigs.github.io/external-dns/"
# # #   chart      = "external-dns"
# # #   version    = "1.19.0"

# # #   wait             = true
# # #   timeout          = 600
# # #   create_namespace = false

# # #   set = [
# # #     # { name = "sources[0]", value = "ingress" },
# # #     # { name = "provider", value = "cloudflare" },

# # #     # # apex domain, e.g. example.com
# # #     # { name = "domainFilters[0]", value = local.dns_record },

# # #     # # { name = "policy", value = "sync" },
# # #     # { name = "registry", value = "txt" },
# # #     # { name = "txtOwnerId", value = module.eks.cluster_name },

# # #     { name = "serviceAccount.create", value = "false" },
# # #     { name = "serviceAccount.name", value = kubernetes_service_account_v1.external_dns.metadata[0].name },

# # #     { name = "env[0].name", value = "CF_API_TOKEN" },
# # #     { name = "env[0].valueFrom.secretKeyRef.name", value = kubernetes_secret_v1.external_dns_cloudflare.metadata[0].name },
# # #     { name = "env[0].valueFrom.secretKeyRef.key", value = "api-token" }
# # #   ]

# # #   depends_on = [
# # #     kubernetes_namespace_v1.external_dns,
# # #     kubernetes_secret_v1.external_dns_cloudflare,
# # #     kubernetes_service_account_v1.external_dns
# # #   ]
# # # }

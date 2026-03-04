# # aws_eks_cluster_iam.tf

# locals {
#   oidc_provider = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#   # oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
# }

# # #############################################
# # IAM Role: SA for AWS Load Balancer Controller
# # #############################################
# # role of Load Balancer Controller
# resource "aws_iam_role" "lbc" {
#   name = "${module.eks.cluster_name}-lbc"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         # Federated = local.oidc_provider_arn
#         Federated = module.eks.oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "${local.oidc_provider}:aud" = "sts.amazonaws.com"
#           "${local.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })
# }

# # policy for LBC
# resource "aws_iam_policy" "lbc" {
#   name   = "${module.eks.cluster_name}-lbc"
#   policy = file("${path.module}/../share/iam_policy.json")
# }

# resource "aws_iam_role_policy_attachment" "lbc" {
#   role       = aws_iam_role.lbc.name
#   policy_arn = aws_iam_policy.lbc.arn
# }

# # #############################################
# # IAM Role: SA for ESO
# # #############################################
# # role of External Secrets Operator
# resource "aws_iam_role" "eso" {
#   name = "${module.eks.cluster_name}-eso"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         # Federated = local.oidc_provider_arn
#         Federated = module.eks.oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "${local.oidc_provider}:aud" = "sts.amazonaws.com"
#           "${local.oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets"
#         }
#       }
#     }]
#   })
# }

# # policy for External Secrets Operator
# data "aws_iam_policy_document" "eso" {
#   # Allow listing/batch on all secrets (needed for certain workflows/features)
#   statement {
#     effect = "Allow"
#     actions = [
#       "secretsmanager:ListSecrets",
#       "secretsmanager:BatchGetSecretValue"
#     ]
#     resources = ["*"]
#   }

#   # Allow read-only access to a scoped set of secrets
#   statement {
#     effect = "Allow"
#     actions = [
#       "secretsmanager:GetResourcePolicy",
#       "secretsmanager:GetSecretValue",
#       "secretsmanager:DescribeSecret",
#       "secretsmanager:ListSecretVersionIds"
#     ]
#     resources = [aws_secretsmanager_secret.app.arn]
#   }
# }

# resource "aws_iam_policy" "eso" {
#   name   = "${var.project_name}-${var.arch}-eso"
#   policy = data.aws_iam_policy_document.eso.json
# }

# resource "aws_iam_role_policy_attachment" "eso" {
#   role       = aws_iam_role.eso.name
#   policy_arn = aws_iam_policy.eso.arn
# }

# # #############################################
# # IAM Role: SA for ESO
# # #############################################
# # data "tls_certificate" "eks" {
# #   url = module.eks.cluster_oidc_issuer_url
# # }

# # resource "aws_iam_openid_connect_provider" "eks" {
# #   client_id_list  = ["sts.amazonaws.om"]
# #   thumbprint_list = [module.eks.cluster_tls_certificate_sha1_fingerprint]
# #   url             = module.eks.cluster_oidc_issuer_url
# # }

# # data "aws_iam_policy_document" "karpenter_controller_policy" {
# #   statement {
# #     actions = ["sts:AssumeRoleWithWebIdentity"]
# #     effect  = "Allow"

# #     condition {
# #       test     = "StringEquals"
# #       variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
# #       values   = ["system:serviceaccount:karpenter:karpenter"]
# #     }

# #     principals {
# #       identifiers = [module.eks.oidc_provider_arn]
# #       type        = "Federated"
# #     }
# #   }
# # }

# # resource "aws_iam_role" "karpenter" {
# #   assume_role_policy = data.aws_iam_policy_document.karpenter_controller_policy.json
# #   name               = "${module.eks.cluster_name}-karpenter"
# # }

# # resource "aws_iam_policy" "karpenter-controller" {
# #   name   = "KarpenterController"
# #   policy = file("${path.module}/../share/karpenter_controller_policy.json")
# # }

# # resource "aws_iam_role_policy_attachment" "karpenter" {
# #   role       = aws_iam_role.karpenter.name
# #   policy_arn = aws_iam_policy.karpenter-controller.arn
# # }

# # resource "aws_iam_instance_profile" "karpenter" {
# #   name = "KarpenterNodeInstanceProfile"
# #   role = aws_iam_role.node_group.name
# # }

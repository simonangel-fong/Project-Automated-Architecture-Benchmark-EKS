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

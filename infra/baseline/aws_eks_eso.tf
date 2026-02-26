# # baseline/aws_eks_eso.tf

# # ###################################
# # IAM Role for serviceaccount in eks
# # ###################################
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
#   statement {
#     effect = "Allow"
#     actions = [
#       "secretsmanager:GetSecretValue",
#       "secretsmanager:DescribeSecret",
#     ]
#     resources = [aws_secretsmanager_secret.db.arn]
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

# # ###################################
# # Kubernetes: create ServiceAccount with Role
# # ###################################
# resource "kubernetes_service_account_v1" "eso" {
#   metadata {
#     name      = "external-secrets"
#     namespace = "external-secrets"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.eso.arn
#     }
#   }
# }

# # ###################################
# # Helm: Install packages
# # ###################################
# # AWS External Secrets
# resource "helm_release" "external_secrets" {
#   name       = "external-secrets"
#   namespace  = "external-secrets"
#   repository = "https://charts.external-secrets.io"
#   chart      = "external-secrets"

#   create_namespace = true

#   set = [
#     {
#       name  = "installCRDs",
#       value = true
#     },
#     {
#       name  = "serviceAccount.create",
#       value = "false"
#     }
#     ,
#     {
#       name  = "serviceAccount.name",
#       value = kubernetes_service_account_v1.eso.metadata[0].name
#     }
#   ]
# }



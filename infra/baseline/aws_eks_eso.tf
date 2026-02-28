# baseline/aws_eks_eso.tf

locals {
  eso_namespace            = "external-secrets"
  eso_serviceaccount       = "external-secrets"
  eso_helm_release         = "external-secrets"
  eso_cluster_secret_store = "aws-secrets-global"
}

# ###################################
# IAM Role for serviceaccount in eks
# ###################################
# role of External Secrets Operator
resource "aws_iam_role" "eso" {
  name = "${module.eks.cluster_name}-eso"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        # Federated = local.oidc_provider_arn
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets"
        }
      }
    }]
  })
}

# policy for External Secrets Operator
data "aws_iam_policy_document" "eso" {
  # Allow listing/batch on all secrets (needed for certain workflows/features)
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
      "secretsmanager:BatchGetSecretValue"
    ]
    resources = ["*"]
  }

  # Allow read-only access to a scoped set of secrets
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [aws_secretsmanager_secret.app.arn]
  }
}

resource "aws_iam_policy" "eso" {
  name   = "${var.project_name}-${var.arch}-eso"
  policy = data.aws_iam_policy_document.eso.json
}

resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso.arn
}

# # ###################################
# # Kubernetes resources
# # ###################################
# # Create ns for eso
# resource "kubernetes_namespace_v1" "eso" {
#   metadata {
#     name = "external-secrets"
#     labels = {
#       "app.kubernetes.io/managed-by" = "terraform"
#     }
#   }
# }

# ###################################
# Helm: Install packages
# ###################################
# AWS External Secrets
resource "helm_release" "external_secrets" {
  name             = local.eso_helm_release
  namespace        = local.eso_namespace
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "2.0.1"
  create_namespace = true

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = local.eso_serviceaccount
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.eso.arn
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "eso" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = local.eso_cluster_secret_store
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = local.eso_serviceaccount
                namespace = local.eso_namespace
              }
            }
          }
        }
      }
    }
  }
}

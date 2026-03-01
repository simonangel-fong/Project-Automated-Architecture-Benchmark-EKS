# baseline/aws_eks_lbc.tf

locals {
  lbc_helm_release        = "aws-load-balancer-controller"
  lbc_helm_namespace      = "kube-system"
  lbc_helm_repository     = "https://aws.github.io/eks-charts"
  lbc_helm_chart          = "aws-load-balancer-controller"
  lbc_helm_version        = "3.1.0"
  lbc_helm_serviceaccount = "aws-load-balancer-controller"
}

# ###################################
# IAM Role for serviceaccount in eks
# ###################################
# role of Load Balancer Controller
resource "aws_iam_role" "lbc" {
  name = "${module.eks.cluster_name}-lbc"

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
          "${local.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

# policy for LBC
resource "aws_iam_policy" "lbc" {
  name   = "${module.eks.cluster_name}-lbc"
  policy = file("${path.module}/../share/iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}

# # ###################################
# # Helm: Install packages
# # ###################################
# resource "helm_release" "lbc" {
#   name       = local.lbc_helm_release
#   namespace  = local.lbc_helm_namespace
#   repository = local.lbc_helm_repository
#   chart      = local.lbc_helm_chart
#   version    = local.lbc_helm_version

#   wait             = true
#   timeout          = 600
#   create_namespace = false

#   values = [
#     yamlencode({
#       clusterName = module.eks.cluster_name
#       region      = var.aws_region
#       vpcId       = module.vpc.vpc_id

#       serviceAccount = {
#         create = true
#         name   = local.lbc_helm_serviceaccount
#         annotations = {
#           "eks.amazonaws.com/role-arn" = aws_iam_role.lbc.arn
#         }
#       }
#     })
#   ]

#   depends_on = [
#     aws_iam_role_policy_attachment.lbc
#   ]
# }

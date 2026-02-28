# baseline/aws_eks_lbc.tf

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
# # Kubernetes: Create ServiceAccount with Role
# # ###################################
# resource "kubernetes_service_account_v1" "lbc" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.lbc.arn
#     }
#     labels = {
#       "app.kubernetes.io/name" = "aws-load-balancer-controller"
#     }
#   }
# }

# # ###################################
# # Helm: Install packages
# # ###################################
# resource "helm_release" "lbc" {
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"

#   wait             = true
#   timeout          = 600
#   create_namespace = false

#   set = [{
#     name  = "clusterName"
#     value = module.eks.cluster_name
#     },

#     {
#       name  = "serviceAccount.create"
#       value = "false"
#     },

#     {
#       name  = "serviceAccount.name"
#       value = kubernetes_service_account_v1.lbc.metadata[0].name
#     }
#     ,
#     {
#       name  = "region"
#       value = var.aws_region
#     },

#     {
#       name  = "vpcId"
#       value = module.vpc.vpc_id
#     }
#   ]

#   depends_on = [
#     aws_iam_role_policy_attachment.lbc,
#     kubernetes_service_account_v1.lbc
#   ]
# }

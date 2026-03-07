# aws_eks_access.tf

locals {
  access_entries = {
    cluster_admin = {
      # principal_arn = "${aws_iam_role.eks_admin_access.arn}"
      principal_arn = var.cluster_admin_arn
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      scope         = "cluster"
      namespaces    = []
      description   = "Human: daily ops and break-glass"
    }
    # cicd_app = {
    #   principal_arn = var.cicd_app_role_arn
    #   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
    #   scope         = "cluster"
    #   namespaces    = []
    #   description   = "CI/CD App pipeline: Helm add-ons and application deployments"
    # }

    # developer = {
    #   principal_arn = var.developer_role_arn
    #   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    #   scope         = "namespace"
    #   namespaces    = var.app_namespaces # e.g. ["app-backend", "app-frontend"]
    #   description   = "Human: app debugging and workload management, namespace-scoped"
    # }
    # auditor = {
    #   principal_arn = var.auditor_role_arn
    #   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    #   scope         = "cluster"
    #   namespaces    = []
    #   description   = "Human: compliance and reporting, read-only"
    # }
  }
}

# # #########################
# # EKS Access Entries
# # #########################
# resource "aws_eks_access_entry" "eks" {
#   for_each = local.access_entries

#   cluster_name  = module.eks.cluster_name
#   principal_arn = each.value.principal_arn
#   type          = "STANDARD"

#   tags = {
#     Description = each.value.description
#     ManagedBy   = "terraform"
#   }
# }

# # Associate the Access Policy to the Entry
# resource "aws_eks_access_policy_association" "eks" {
#   for_each = local.access_entries

#   cluster_name  = module.eks.cluster_name
#   principal_arn = each.value.principal_arn
#   policy_arn    = each.value.policy_arn

#   access_scope {
#     type       = each.value.scope
#     namespaces = each.value.scope == "namespace" ? each.value.namespaces : []
#   }

#   depends_on = [aws_eks_access_entry.eks]
# }

# # #########################
# # IAM Role: EKS Cluster Admin
# # #########################
# resource "aws_iam_role" "eks_admin_access" {
#   name = "${module.eks.cluster_name}-role-admin-access"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           AWS = var.cluster_admin_arn
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_admin_describe" {
#   role       = aws_iam_role.eks_admin_access.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }


resource "aws_eks_access_entry" "eks" {
  for_each = local.access_entries

  cluster_name  = module.eks.cluster_name
  principal_arn = each.value.principal_arn
  type          = "STANDARD"

  tags = {
    Description = each.value.description
    ManagedBy   = "terraform"
  }
}

resource "aws_eks_access_policy_association" "eks" {
  for_each = local.access_entries

  cluster_name  = module.eks.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.scope
    namespaces = each.value.scope == "namespace" ? each.value.namespaces : []
  }

  depends_on = [aws_eks_access_entry.eks]
}

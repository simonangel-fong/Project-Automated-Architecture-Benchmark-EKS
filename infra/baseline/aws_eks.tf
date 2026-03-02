# baseline/aws_eks.tf

locals {
  oidc_provider = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  # oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
}

# #########################
# EKS Cluster
# #########################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.kube_version

  # Network
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets
  endpoint_public_access = true

  # API-based authentication
  authentication_mode = "API"
  # Adds the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true
}

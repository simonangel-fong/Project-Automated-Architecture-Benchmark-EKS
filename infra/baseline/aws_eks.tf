# baseline/aws_eks.tf

locals {
  oidc_provider     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
}

# #########################
# EKS Cluster
# #########################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.kube_version

  addons = {
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
  }

  endpoint_public_access = true

  # Adds the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = var.node_instance_types
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size

      capacity_type = "ON_DEMAND"
    }
  }
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

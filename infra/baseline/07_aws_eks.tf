# baseline/aws_eks.tf

################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name               = local.cluster_name
  kubernetes_version = "1.35"

  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  control_plane_scaling_config = {
    tier = "standard"
  }

  addons = {
    # eks-pod-identity-agent = {
    #   before_compute = true
    # }
    # vpc-cni = {
    #   before_compute = true
    # }
    # kube-proxy = {}
    # coredns = {}
  }

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = [for s in aws_subnet.private : s.id]
  control_plane_subnet_ids = [for s in aws_subnet.private : s.id]

  eks_managed_node_groups = {
    bootstrap = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]

      desired_size = 1
      min_size     = 1
      max_size     = 2

      labels = {
        "karpenter.sh/controller" = "true"
      }
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name
  }
}

# ################################################################################
# # Karpenter
# ################################################################################
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = local.cluster_name

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix = false

  node_iam_role_name              = local.cluster_name
  create_pod_identity_association = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}


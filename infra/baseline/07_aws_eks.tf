# # baseline/aws_eks.tf

# # resource "aws_iam_role" "cluster" {
# #   name = "${var.project_name}-${var.arch}-cluster-role"

# #   assume_role_policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [{
# #       Action = "sts:AssumeRole"
# #       Effect = "Allow"
# #       Sid    = ""
# #       Principal = {
# #         Service = "ec2.amazonaws.com"
# #       }
# #     }]
# #   })
# # }

# # resource "aws_iam_role_policy_attachment" "cluster" {
# #   role       = aws_iam_role.cluster.name
# #   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# # }


# ################################################################################
# # EKS Module
# ################################################################################
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "21.15.1"

#   name               = local.cluster_name
#   kubernetes_version = "1.35"

#   enable_cluster_creator_admin_permissions = true
#   endpoint_public_access                   = true

#   control_plane_scaling_config = {
#     tier = "standard"
#   }

#   addons = {
#     coredns = {
#       before_compute = true
#     }
#     eks-pod-identity-agent = {
#       before_compute = true
#     }
#     kube-proxy = {}
#     vpc-cni = {
#       before_compute = true
#     }
#   }

#   vpc_id                   = module.vpc.vpc_id
#   subnet_ids               = module.vpc.private_subnets
#   control_plane_subnet_ids = module.vpc.intra_subnets

#   eks_managed_node_groups = {
#     karpenter = {
#       ami_type       = "BOTTLEROCKET_x86_64"
#       instance_types = ["t3.medium"]

#       desired_size = 1
#       min_size     = 1
#       max_size     = 2

#       labels = {
#         "karpenter.sh/controller" = "true"
#       }
#     }
#   }

#   node_security_group_tags = {
#     "karpenter.sh/discovery" = local.cluster_name
#   }
# }

# # # ################################################################################
# # # # Karpenter
# # # ################################################################################
# # module "karpenter" {
# #   source = "terraform-aws-modules/eks/aws//modules/karpenter"

# #   cluster_name = module.eks.cluster_name

# #   # Name needs to match role name passed to the EC2NodeClass
# #   node_iam_role_use_name_prefix   = false

# #   node_iam_role_name              = local.cluster_name
# #   create_pod_identity_association = true

# #   # Used to attach additional IAM policies to the Karpenter node IAM role
# #   node_iam_role_additional_policies = {
# #     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# #   }
# # }


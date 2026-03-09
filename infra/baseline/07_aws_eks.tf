# # aws_eks.tf

# ################################################################################
# # EKS Module
# ################################################################################
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "21.15.1"

#   name               = local.cluster_name
#   kubernetes_version = "1.35"

#   # api access
#   authentication_mode = "API_AND_CONFIG_MAP"
#   # enable_cluster_creator_admin_permissions = true
#   endpoint_public_access = true

#   control_plane_scaling_config = {
#     tier = "standard"
#   }

#   vpc_id                   = aws_vpc.main.id
#   subnet_ids               = [for s in aws_subnet.private : s.id]
#   control_plane_subnet_ids = [for s in aws_subnet.private : s.id]

#   eks_managed_node_groups = {
#     bootstrap = {
#       ami_type       = "BOTTLEROCKET_x86_64"
#       instance_types = var.node_instance_types

#       desired_size = var.desired_size
#       min_size     = var.min_size
#       max_size     = var.max_size

#       labels = {
#         "karpenter.sh/controller" = "true"
#       }
#     }
#   }

#   node_security_group_tags = {
#     "karpenter.sh/discovery" = local.cluster_name
#   }
# }

# baseline/main.tf

data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

# #########################
# VPC 
# #########################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "${var.project_name}-${var.arch}"
  cidr = "10.0.0.0/16"

  azs             = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

# # #########################
# # EKS Cluster
# # #########################
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 21.0"

#   name               = "${var.project_name}-${var.arch}"
#   kubernetes_version = "1.34"

#   addons = {
#     kube-proxy = {}
#     vpc-cni = {
#       before_compute = true
#     }
#     coredns = {}
#     eks-pod-identity-agent = {
#       before_compute = true
#     }
#   }

#   endpoint_public_access = true

#   # Adds the current caller identity as an administrator
#   enable_cluster_creator_admin_permissions = true

#   vpc_id                   = module.vpc.vpc_id
#   subnet_ids               = module.vpc.public_subnet_id
#   control_plane_subnet_ids = module.vpc.private_subnet_id

#   # EKS Managed Node Group
#   eks_managed_node_groups = {
#     default = {
#       ami_type       = "BOTTLEROCKET_x86_64"
#       instance_types = var.node_instance_types

#       min_size     = var.min_size
#       max_size     = var.max_size
#       desired_size = var.desired_size

#       capacity_type = "ON_DEMAND"
#     }
#   }
# }

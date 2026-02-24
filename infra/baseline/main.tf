# baseline/main.tf
module "vpc" {
  source     = "../module/vpc"
  aws_region = var.aws_region
  vpc_name   = "${var.project_name}-${var.arch}"
  vpc_cidr   = "10.0.0.0/16"
}

module "eks" {
  source             = "../module/eks"
  region             = var.aws_region
  eks_name           = "${var.project_name}-${var.arch}"
  private_subnet_ids = module.vpc.public_subnet_id
  admin_arn          = data.aws_caller_identity.current.arn
}

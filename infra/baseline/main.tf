module "vpc" {
  source     = "../module/vpc"
  aws_region = var.aws_region
  vpc_name   = "${var.project_name}-${var.arch}"
  vpc_cidr   = "10.0.0.0/16"
}

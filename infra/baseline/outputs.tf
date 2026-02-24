# baseline/output.tf
# output "private_subnet_id" {
#   value = module.vpc.private_subnet_id
# }

output "eks_kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.eks_cluster_name}"

}


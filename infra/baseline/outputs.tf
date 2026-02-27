# baseline/output.tf
output "api_url" {
  value = "https://${local.dns_record}"
}

# output "eks_kubeconfig_command" {
#   value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"

# }

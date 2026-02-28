# baseline/output.tf
output "api_url" {
  value = "https://${local.dns_record}"
}

# output "role_eso" {
#   value = aws_iam_role.eso.arn
# }
# output "role_lbc" {
#   value = aws_iam_role.lbc.arn
# }


# output "eks_kubeconfig_command" {
#   value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"

# }

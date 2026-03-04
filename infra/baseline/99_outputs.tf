# # baseline/output.tf
# output "api_url" {
#   value = "https://${local.dns_record}"
# }

# output "cluster_name" {
#   value = module.eks.cluster_name
# }

# output "vpc_id" {
#   value = module.vpc.vpc_id
# }

# output "iam_role_eso" {
#   value = aws_iam_role.eso.arn
# }

# output "iam_role_lbc" {
#   value = aws_iam_role.lbc.arn
# }

# output "cluster_endpoint" {
#   value = module.eks.cluster_endpoint
# }

# # output "queue_name" {
# #   value = module.karpenter.queue_name
# # }

# output "eks_kubeconfig_command" {
#   value = "\naws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}\n"
# }

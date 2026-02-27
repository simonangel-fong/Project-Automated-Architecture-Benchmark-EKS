# baseline/output.tf
output "api_url" {
  value = "https://${cloudflare_record.dns_record.hostname}"
}

# output "eks_kubeconfig_command" {
#   value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"

# }

output "alb_dns" {
  value = data.aws_lb.alb.dns_name
}


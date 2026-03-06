# baseline/output.tf
output "api_url" {
  value = "https://${local.dns_record}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "queue_name" {
  value = module.karpenter.queue_name
}

output "iam_role_eso" {
  value = aws_iam_role.eso.arn
}

output "iam_role_lbc" {
  value = aws_iam_role.lbc.arn
}

output "eks_kubeconfig_command" {
  value = <<-EOF

    aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}
    
  EOF
}

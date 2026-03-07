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

output "export_env" {
  value = <<-EOF

    export ARCH="${var.arch}"
    export REGION="${var.aws_region}"

    export VPC_ID="${aws_vpc.main.id}"
    export CLUSTER_NAME="${module.eks.cluster_name}"
    export CLUSTER_ENDPOINT="${module.eks.cluster_endpoint}"
    export QUEUE_NAME="${module.karpenter.queue_name}"

    export IAM_ESO_ROLE_ARN="${aws_iam_role.eso.arn}"
    export IAM_LBC_ROLE_ARN="${aws_iam_role.lbc.arn}"

    aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}
    
  EOF
}

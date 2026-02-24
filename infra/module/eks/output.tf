# module/eks/output.tf
output "eks_cluster_name" {
  description = "Kubernetes Cluster Name"
  value = aws_eks_cluster.cluster.name
}

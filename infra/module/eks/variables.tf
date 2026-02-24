# module/eks/variables.tf

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "eks_name" {
  description = "EKS name"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list
}

variable "admin_arn" {
  description = "Cluster admin arn"
  type        = string
}
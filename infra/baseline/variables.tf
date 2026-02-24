# baseline/variables.tf
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eks-benchmark"
}

variable "arch" {
  description = "Architecture name"
  type        = string
  default     = "baseline"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "tags" {
  description = "Extra tags applied to all resources via provider default_tags."
  type        = map(string)
  default     = {}
}

# current identity
data "aws_caller_identity" "current" {}
# baseline/variables.tf
# ##############################
# Project
# ##############################
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eks-benchmark"
}

variable "arch" {
  description = "Architecture name"
  type        = string
  default     = "kafka"
}

variable "test_version" {
  type = string
}


# ##############################
# AWS
# ##############################
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

variable "cluster_admin_arn" {
  description = "AWS arn for eks cluster admin access."
  type        = string
}

# ##############################
# Cloudflare
# ##############################
variable "cloudflare_api_token" { type = string }
variable "cloudflare_zone_id" { type = string }

# ##############################
# EKS
# ##############################
variable "kube_version" {
  type    = string
  default = "1.35"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "app_namespace" {
  type    = string
  default = "backend"
}

variable "github_cicd_role_arn" {
  type = string
}

# ##############################
# AWS RDS
# ##############################
variable "instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "rds_max_connection" {
  type    = number
  default = 400
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_app_pwd" {
  type = string
}

variable "db_readonly_pwd" {
  type = string
}

# ##############################
# AWS Elasticache
# ##############################
variable "redis_node_type" {
  description = "Instance type for Redis cache nodes"
  type        = string
  default     = "cache.t4g.micro"
}

# ##############################
# AWS MSK
# ##############################
variable "kafka_topic" {
  type    = string
  default = "telemetry"
}

variable "kafka_instance_type" {
  type    = string
  default = "kafka.t3.small"
}

variable "kafka_volume_size" {
  type    = number
  default = 20
}

variable "kafka_broker_count" {
  type    = number
  default = 3
}

# ##############################
# AWS Cloudfront
# ##############################
variable "domain_name" {
  type    = string
  default = "arguswatcher.net"
}

locals {
  dns_record = "eks-benchmark-${var.arch}.${var.domain_name}"
}

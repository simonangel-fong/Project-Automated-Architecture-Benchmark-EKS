# module/vpc/variables.tf
variable "region" {
  type = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC cidr"
  type        = string
}

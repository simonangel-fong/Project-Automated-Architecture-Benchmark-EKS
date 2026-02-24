# module/vpc/output.tf
output "private_subnet_id" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_id" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

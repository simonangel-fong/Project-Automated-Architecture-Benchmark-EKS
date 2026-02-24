output "private_subnet_id" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

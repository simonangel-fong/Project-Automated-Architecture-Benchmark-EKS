
# resource "aws_secretsmanager_secret" "db" {
#   name = "${var.project_name}-${var.arch}-db-credentials"
#   tags = {
#     Project      = var.project_name
#     Architecture = var.arch
#     ManagedBy    = "terraform"
#   }
# }

# resource "aws_secretsmanager_secret_version" "db" {
#   secret_id = aws_secretsmanager_secret.db.id

#   secret_string = jsonencode({
#     username = var.db_username
#     password = var.db_password
#     host     = aws_db_instance.postgres.address
#     port     = aws_db_instance.postgres.port
#     dbname   = aws_db_instance.postgres.db_name
#   })
# }

# # resource "kubernetes_secret" "awssm-secret" {
# #   metadata {
# #     name = "awssm-secret"
# #   }

# #   data = {
# #     access-key = "admin"
# #     password = "P4ssw0rd"
# #   }

# #   type = "kubernetes.io/basic-auth"
# # }
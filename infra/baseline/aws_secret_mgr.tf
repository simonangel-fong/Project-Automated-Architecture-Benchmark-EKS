
resource "aws_secretsmanager_secret" "app" {
  name = "${var.project_name}-${var.arch}"

  recovery_window_in_days = 0

  tags = {
    Project      = var.project_name
    Architecture = var.arch
    ManagedBy    = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    db_host     = aws_db_instance.postgres.address
    db_port     = aws_db_instance.postgres.port
    db_dbname   = aws_db_instance.postgres.db_name
    db_username = var.db_username
    db_password = var.db_password
  })
}

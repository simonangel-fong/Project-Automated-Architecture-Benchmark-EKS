# aws_secret_mgr.tf

locals {
  flyway_url = "jdbc:postgresql://${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
}

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
    db_host                 = aws_db_instance.postgres.address
    db_port                 = aws_db_instance.postgres.port
    db_dbname               = aws_db_instance.postgres.db_name
    db_username             = var.db_username
    db_password             = var.db_password
    flyway_url              = local.flyway_url
    db_app_pwd              = var.db_app_pwd
    db_readonly_pwd         = var.db_readonly_pwd
    redis_host              = aws_elasticache_replication_group.redis.primary_endpoint_address
    redis_port              = aws_elasticache_replication_group.redis.port
    kafka_use_msk_auth      = aws_msk_cluster.kafka.bootstrap_brokers_sasl_iam
    kafka_bootstrap_servers = true
    kafka_topic             = var.kafka_topic
  })
}

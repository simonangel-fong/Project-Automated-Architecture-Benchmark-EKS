# aws_msk_iam.tf

locals {
  msk_cluster_arn_suffix = replace(
    aws_msk_cluster.kafka.arn,
    "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/",
    ""
  )

  eks_oidc_provider_host = module.eks.oidc_provider
  kafka_topic_name       = var.kafka_topic

  role_name_msk_fastapi      = "${local.msk_name}-msk-fastapi"
  role_name_msk_topic_admin  = "${local.msk_name}-msk-topic-admin"
  role_name_msk_redis_outbox = "${local.msk_name}-msk-redis-outbox"

}

#################################
# IAM role: FastAPI IRSA
#################################
resource "aws_iam_role" "msk-fastapi" {
  name = local.role_name_msk_fastapi

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowIrsaForFastapiServiceAccount"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.eks_oidc_provider_host}:aud" = "sts.amazonaws.com"
            "${local.eks_oidc_provider_host}:sub" = "system:serviceaccount:backend:msk-fastapi"
          }
        }
      }
    ]
  })
}

# IAM policy: FastAPI producer
resource "aws_iam_policy" "msk-fastapi" {
  name = local.role_name_msk_fastapi

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ClusterConnect"
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = [
          aws_msk_cluster.kafka.arn
        ]
      },
      {
        Sid    = "WriteTopic"
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:WriteData"
        ]
        Resource = [
          "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/${local.msk_cluster_arn_suffix}/${local.kafka_topic_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "msk-fastapi" {
  role       = aws_iam_role.msk-fastapi.name
  policy_arn = aws_iam_policy.msk-fastapi.arn
}

#################################
# IAM role: Topic Admin IRSA
#################################
resource "aws_iam_role" "msk_topic_admin" {
  name = local.role_name_msk_topic_admin

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowIrsaForTopicAdminServiceAccount"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.eks_oidc_provider_host}:aud" = "sts.amazonaws.com"
            "${local.eks_oidc_provider_host}:sub" = "system:serviceaccount:backend:msk-topic-admin"
          }
        }
      }
    ]
  })
}

# IAM policy: topic creation
resource "aws_iam_policy" "msk_topic_admin" {
  name = local.role_name_msk_topic_admin

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ClusterConnect"
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = [
          aws_msk_cluster.kafka.arn
        ]
      },
      {
        Sid    = "TopicAdmin"
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:DescribeTopicDynamicConfiguration",
          "kafka-cluster:CreateTopic",
          "kafka-cluster:AlterTopic"
        ]
        Resource = [
          "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/${local.msk_cluster_arn_suffix}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "msk_topic_admin" {
  role       = aws_iam_role.msk_topic_admin.name
  policy_arn = aws_iam_policy.msk_topic_admin.arn
}


#################################
# IAM role: Redis Outbox IRSA
#################################
resource "aws_iam_role" "msk-redis-outbox" {
  name = local.role_name_msk_redis_outbox

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowIrsaForRedisOutboxServiceAccount"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.eks_oidc_provider_host}:aud" = "sts.amazonaws.com"
            "${local.eks_oidc_provider_host}:sub" = "system:serviceaccount:backend:msk-redis-outbox"
          }
        }
      }
    ]
  })
}

# IAM policy: Redis Outbox producer
resource "aws_iam_policy" "msk-redis-outbox" {
  name = local.role_name_msk_redis_outbox

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ClusterConnect"
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = [
          aws_msk_cluster.kafka.arn
        ]
      },
      {
        Sid    = "WriteTopic"
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:WriteData"
        ]
        Resource = [
          "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/${local.msk_cluster_arn_suffix}/${local.kafka_topic_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "msk-redis-outbox" {
  role       = aws_iam_role.msk-redis-outbox.name
  policy_arn = aws_iam_policy.msk-redis-outbox.arn
}

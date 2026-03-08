# aws_msk_iam.tf

resource "aws_iam_role" "eks_to_msk" {
  name = "${local.msk_name}-eks-to-msk"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "msk_access" {
  name = "${local.msk_name}-msk-access"

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
        Sid    = "TopicAccess"
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:CreateTopic",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ]
        Resource = [
          "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.kafka.cluster_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_to_msk" {
  role       = aws_iam_role.eks_to_msk.name
  policy_arn = aws_iam_policy.msk_access.arn
}

# enable sa "fastapi-msk"
resource "aws_eks_pod_identity_association" "fastapi-msk" {
  cluster_name    = module.eks.cluster_name
  namespace       = "backend"
  service_account = "fastapi-msk"

  role_arn = aws_iam_role.eks_to_msk.arn
}

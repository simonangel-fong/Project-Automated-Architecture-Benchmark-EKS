# aws_eks_addon.tf

# #########################
# EKS Add-on: Pod Identity
# #########################
resource "aws_eks_addon" "pod_identity" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.10-eksbuild.2"

  resolve_conflicts_on_update = "PRESERVE"
}

# #########################
# EKS Add-on: Kube proxy
# #########################
resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "kube-proxy"
  addon_version = "v1.35.0-eksbuild.2"

  depends_on = [module.eks.eks_managed_node_groups]
}

# #########################
# EKS Add-on: CNI
# #########################
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "vpc-cni"
  addon_version = "v1.21.1-eksbuild.3"

  resolve_conflicts_on_update = "PRESERVE"
}

# #########################
# EKS Add-on: Coredns
# #########################
resource "aws_eks_addon" "coredns" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "coredns"
  addon_version = "v1.13.2-eksbuild.1"

  depends_on = [module.eks.eks_managed_node_groups]
}

# ###################################
# EKS Add-on: Metrics Server
# ###################################
resource "aws_eks_addon" "cloudwatch" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = "v4.10.1-eksbuild.1"

  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    containerLogs = {
      enabled = false
    }

    agent = {
      config = {
        logs = {
          metrics_collected = {
            kubernetes = {
              enhanced_container_insights = true
            }
          }
        }
      }
    }
  })

  pod_identity_association {
    role_arn        = aws_iam_role.cloudwatch.arn
    service_account = "cloudwatch-agent"
  }

  depends_on = [module.eks]
}

# IAM Role policy: EKS CloudWatch
data "aws_iam_policy_document" "cloudwatch_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

# IAM Role: EKS CloudWatch
resource "aws_iam_role" "cloudwatch" {
  name               = "${module.eks.cluster_name}-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_cloudwatch" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

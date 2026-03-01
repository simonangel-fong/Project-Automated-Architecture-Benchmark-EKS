# baseline/aws_eks.tf

locals {
  oidc_provider = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  # oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
}

# #########################
# EKS Cluster
# #########################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.kube_version

  addons = {
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
  }

  endpoint_public_access = true

  # Adds the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = var.node_instance_types
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size

      capacity_type = "ON_DEMAND"
    }
  }
}
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [module.eks]

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = jsonencode({
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
    role_arn        = aws_iam_role.cw_observability.arn
    service_account = "cloudwatch-agent"
  }

}

# #########################
# IAM Role for CloudWatch Observability (Pod Identity)
# #########################
data "aws_iam_policy_document" "cw_obs_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cw_observability" {
  name               = "${module.eks.cluster_name}-cw-observability"
  description        = "Pod Identity role for CloudWatch Observability addon on ${module.eks.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.cw_obs_assume.json
}

resource "aws_iam_role_policy_attachment" "cw_observability_cloudwatch" {
  role       = aws_iam_role.cw_observability.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cw_observability_xray" {
  role       = aws_iam_role.cw_observability.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

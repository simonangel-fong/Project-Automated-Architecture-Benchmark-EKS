# baseline/providers.tf
# ##############################
# Provider: AWS
# ##############################
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Project      = var.project_name
        Architecture = var.arch
        ManagedBy    = "terraform"
      }
    )
  }
}

# ##############################
# Provider: Cloudflare
# ##############################
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ##############################
# Provider: Kubernetes
# ##############################
data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# ##############################
# Provider: Helm
# ##############################
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

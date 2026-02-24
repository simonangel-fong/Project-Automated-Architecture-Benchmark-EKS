# baseline/providers.tf
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

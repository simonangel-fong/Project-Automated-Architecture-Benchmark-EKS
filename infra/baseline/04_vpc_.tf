# # baseline/main.tf
# locals {
#   vpc_name     = "${var.project_name}-${var.arch}"
#   cluster_name = "${var.project_name}-${var.arch}"
# }

# # #########################
# # VPC 
# # #########################
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "6.6.0"

#   name = local.vpc_name
#   cidr = "10.0.0.0/16"

#   azs             = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#   }

#   public_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/elb"                      = "1"
#     "karpenter.sh/discovery"                      = local.cluster_name
#   }

#   private_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/internal-elb"             = "1"
#   }
# }

# aws_vpc.tf

locals {
  vpc_name     = "${var.project_name}-${var.arch}"
  cluster_name = "${var.project_name}-${var.arch}"
}

# ##############################
# VPC
# ##############################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
  }
}

# ##############################
# Internet Gateway
# ##############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.vpc_name
  }
}

# ##############################
# Route Table
# ##############################
# rt: default, private
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${local.vpc_name}-private"
  }
}

# rt public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.vpc_name}-public"
  }
}

# ##############################
# AZ
# ##############################
data "aws_availability_zones" "available" {
  state = "available"
}

# ##############################
# Private subnet
# ##############################
resource "aws_subnet" "private" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, index(data.aws_availability_zones.available.names, each.value) + 10)
  availability_zone = each.value

  tags = {
    Name = "${local.vpc_name}-${each.value}-private-subnet"
  }
}

# ##############################
# Public subnet
# ##############################
resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, index(data.aws_availability_zones.available.names, each.value) + 100)
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.vpc_name}-${each.value}-public-subnet"
  }
}

# ##############################
# Route Table Associations
# ##############################
resource "aws_route_table_association" "default" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_default_route_table.default.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

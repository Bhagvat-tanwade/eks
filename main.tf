terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ==========================================
# VPC
# ==========================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name = "med-erp-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# ==========================================
# EKS CLUSTER + NODE GROUP
# ==========================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.0"

  name               = "med-erp-cluster"
  kubernetes_version = "1.36"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # ========================================
  # Managed Node Group
  # ========================================

  eks_managed_node_groups = {

    node1 = {

      name = "med-erp-node1"

      instance_types = ["t3.medium"]

      capacity_type = "ON_DEMAND"

      min_size     = 2
      max_size     = 3
      desired_size = 2

      disk_size = 20
    }
  }

  tags = {
    Project     = "medical-erp"
    Environment = "dev"
  }
}

# ==========================================
# OUTPUTS
# ==========================================

output "node_group_name" {
  value = module.eks.eks_managed_node_groups["node1"].node_group_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "node_group_name" {
  value = module.eks.eks_managed_node_groups["node1"].node_group_name
}

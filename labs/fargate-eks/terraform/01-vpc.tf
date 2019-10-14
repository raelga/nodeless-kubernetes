locals {
  region = "eu-west-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name               = "lab-net"
  cidr               = "10.66.0.0/16"
  azs                = ["${local.region}a", "${local.region}b"]
  private_subnets    = []
  public_subnets     = ["10.66.0.0/24", "10.66.1.0/24"]
  enable_nat_gateway = false

  public_subnet_tags = {
    Name = "lab-subnet"
  }

  tags = {
    Owner                                             = "roi"
    Environment                                       = "lab"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  vpc_tags = {
    Name = "lab-net"
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name               = "lab-net"
  cidr               = "10.66.0.0/16"
  azs                = ["eu-west-1a", "eu-west-1b"]
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

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "default_security_group" {
  value = module.vpc.default_security_group_id
}
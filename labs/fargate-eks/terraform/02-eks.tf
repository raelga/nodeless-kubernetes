locals {
  eks_cluster_name = "lab-eks"
}

resource "aws_eks_cluster" "eks" {
  name                      = local.eks_cluster_name
  role_arn                  = aws_iam_role.cluster.arn
  version                   = "1.14"
  enabled_cluster_log_types = ["api", "scheduler", "controllerManager", "authenticator", "api"]

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = module.vpc.public_subnets
  }

  timeouts {
    create = "15m"
    delete = "15m"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.cluster
  ]
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_ca" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

resource "aws_security_group" "cluster" {
  name_prefix = "eks"
  description = "EKS cluster security group."
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_iam_role" "cluster" {
  name_prefix        = "eks"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Sid": "EKSClusterAssumeRole",
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "eks.amazonaws.com"
    }
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.eks_cluster_name}/cluster"
  retention_in_days = "1"
}

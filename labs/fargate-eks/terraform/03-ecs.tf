locals {
  ecs_cluster_name = "lab-ecs"
}

resource "aws_ecs_cluster" "fargate" {
  name = local.ecs_cluster_name
}

resource "aws_iam_role" "fargate_default" {
  name               = "tf-fargate-execution-role"
  assume_role_policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = "${aws_iam_role.fargate_default.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/aws/ecs/${local.ecs_cluster_name}/task"
  retention_in_days = "1"
  # kms_key_id        = var.cluster_log_kms_key_id
  # tagAmazonECSTaskExecutionRolePolicys              = var.tags
}

resource "aws_security_group" "pod_default" {
  name_prefix = "pod"
  description = "Security Group for pods run in the Fargate provider"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "pod_ingress_internet" {
  description       = "Allow pod access from the Internet."
  protocol          = "tcp"
  security_group_id = aws_security_group.pod_default.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "pod_egress_internet" {
  description       = "Allow pod access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.pod_default.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  type              = "egress"
}
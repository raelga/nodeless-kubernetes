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
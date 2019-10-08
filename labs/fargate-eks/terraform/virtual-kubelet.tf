# virtual-kubelet role to create tasks in ECS
resource "aws_iam_role" "virtual_kubelet" {
  name               = "tf-virtual-kubelet-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
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
EOF
}

resource "aws_iam_role_policy_attachment" "virtual_kubelet" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role       = aws_iam_role.virtual_kubelet.name
}

resource "aws_iam_role_policy" "virtual_kubelet" {
  name = "eks-access"
  role = aws_iam_role.virtual_kubelet.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "virtual_kubelet" {
  family                   = "virtual-kubelet"
  # This is for the fargate service to be able to
  # access ECR
  execution_role_arn       = aws_iam_role.fargate_default.arn
  # This is for virtual-kubelet to be able to talk to talk
  # to other AWS APIs
  task_role_arn            = aws_iam_role.virtual_kubelet.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # Tricky thing: only certain combinations of memory and cpu
  # are allowed when using Fargate
  cpu                   = "256"
  memory                = "512"
  container_definitions = "${file("ecs-task-definitions/virtual-kubelet.json")}"
}

resource "aws_ecs_service" "virtual_kubelet" {
  name            = "virtual-kubelet"
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.virtual_kubelet.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    # security_groups  = [aws_security_group.ecs_tasks.id]
    subnets = module.vpc.public_subnets
    assign_public_ip = "true"
  }

  depends_on = [aws_iam_role_policy_attachment.virtual_kubelet, aws_iam_role_policy.virtual_kubelet]
}

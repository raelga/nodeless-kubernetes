/* resource "aws_ecs_service" "virtual_kubelet" {
  name            = "virtual-kubelet"
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.virtual_kubelet.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = "true"
  }

  depends_on = [aws_iam_role_policy_attachment.virtual_kubelet, aws_iam_role_policy.virtual_kubelet]
}

resource "aws_ecs_task_definition" "virtual_kubelet" {
  family = "virtual-kubelet"
  # This is for the fargate service to be able to
  # access ECR
  execution_role_arn = aws_iam_role.fargate_default.arn
  # This is for virtual-kubelet to be able to talk to talk
  # to other AWS APIs
  task_role_arn            = aws_iam_role.virtual_kubelet.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # Tricky thing: only certain combinations of memory and cpu
  # are allowed when using Fargate
  cpu    = "256"
  memory = "512"
  # container_definitions = "${file("ecs-task-definitions/virtual-kubelet.json")}"
  container_definitions = <<DEFINITION
[
  {
    "name": "virtual-kubelet",
    "image": "${aws_ecr_repository.virtual-kubelet.repository_url}:latest",
    "cpu": 256,
    "memory": 512,
    "environment": [
      {
        "name": "KUBELET_PORT",
        "value": "10250"
      },
      {
        "name": "EKS_CLUSTER_NAME",
        "value": "${local.eks_cluster_name}"
      },
      {
        "name": "FARGATE_CLUSTER_REGION",
        "value": "${local.region}"
      },
      {
        "name": "FARGATE_CLUSTER_NAME",
        "value": "${local.ecs_cluster_name}"
      },
      {
        "name": "FARGATE_SGS",
        "value": "\"${aws_security_group.pod_default.id}\""
      },
      {
        "name": "FARGATE_SUBNETS",
        "value": "${format("\\\"%s\\\",\\\"%s\\\"", module.vpc.public_subnets[0], module.vpc.public_subnets[1])}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/aws/ecs/${local.ecs_cluster_name}/task",
        "awslogs-region": "${local.region}",
        "awslogs-stream-prefix": "virtual-kubelet"
      }
    }
  }
]
DEFINITION
}

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

output virtual_kubelet_role_arn {
  value = aws_iam_role.virtual_kubelet.arn
}
 */
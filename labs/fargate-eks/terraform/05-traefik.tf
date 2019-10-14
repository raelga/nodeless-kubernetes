resource "aws_ecs_service" "traefik" {
  name            = "traefik"
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.traefik.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = "true"
    security_groups  = [aws_security_group.traefik.id]
  }
}

resource "aws_ecs_task_definition" "traefik" {
  family             = "traefik"
  execution_role_arn = aws_iam_role.fargate_default.arn
  # task_role_arn            = aws_iam_role.traefik.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # Tricky thing: only certain combinations of memory and cpu
  # are allowed when using Fargate
  cpu                   = "256"
  memory                = "512"
  container_definitions = <<DEFINITION
[
  {
    "name": "traefik",
    "image": "${aws_ecr_repository.traefik.repository_url}:latest",
    "cpu": 256,
    "memory": 512,
    "command": [
      "--api.insecure",
      "--accesslog",
      "--entrypoints.web.Address=:80",
      "--providers.kubernetesingress=true",
      "--providers.kubernetesingress.endpoint=${aws_eks_cluster.eks.endpoint}",
      "--providers.kubernetesingress.certauthfilepath=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
      "--providers.kubernetesingress.token=eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRyYWVmaWstaW5ncmVzcy1jb250cm9sbGVyLXRva2VuLXFmcGp2Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRyYWVmaWstaW5ncmVzcy1jb250cm9sbGVyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYzhjNjMyYTgtZWRmOC0xMWU5LTg1M2ItMGEyZjRkMTJjOGNjIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6dHJhZWZpay1pbmdyZXNzLWNvbnRyb2xsZXIifQ.V08U46zN2cJylZcsw3eeA9eWeQXxhtiXRbRR_1Y2UzjrRPg3lK9XKi0DcB-f0JT29WKvIJROu5jCUIa7DP-8QP-uP9VGPM61zg9I-wsmIYhxdDoHVKO_jhQuXs1LZ9mUizxYG7_653THdBpU8e8SaLki8XS1n8HeK1Sqt8tNZ_BbEffBoN7SNEBqczLY1GfOmL74iRcC8bBERcGWfHNt_bcw40wnmDbnyiHGLjbnxGELN8t0cHdJA58_GoAdVFZjyzHzFvkp9hFhnsC3z32xsWynlbf6OmvO23V81QCkOh8bL9WpnFerzg4jKNk25VZvbQw7BCwmH28SAuEp-1bGNA"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/aws/ecs/${local.ecs_cluster_name}/task",
        "awslogs-region": "${local.region}",
        "awslogs-stream-prefix": "traefik"
      }
    }
  }
]
DEFINITION
}

resource "aws_security_group" "traefik" {
  name_prefix = "pod"
  description = "Security Group for Traefik"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "traefik_ingress_internet" {
  description       = "Allow traefik access from the Internet."
  protocol          = "tcp"
  security_group_id = aws_security_group.traefik.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "traefik_egress_internet" {
  description       = "Allow traefik access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.traefik.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  type              = "egress"
}

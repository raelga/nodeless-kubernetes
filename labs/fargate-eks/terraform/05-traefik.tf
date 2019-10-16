/* resource "aws_ecs_service" "traefik" {
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

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "traefik"
    container_port   = 80
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 4.0"

  target_groups_defaults = {
    cookie_duration                  = 86400
    deregistration_delay             = 300
    health_check_interval            = 10
    health_check_healthy_threshold   = 3
    health_check_path                = "/"
    health_check_port                = "traffic-port"
    health_check_timeout             = 5
    health_check_unhealthy_threshold = 3
    health_check_matcher             = "200-299"
    stickiness_enabled               = true
    target_type                      = "ip"
    slow_start                       = 0
  }
  load_balancer_name       = "traefik"
  security_groups          = [aws_security_group.alb.id]
  subnets                  = module.vpc.public_subnets
  vpc_id                   = module.vpc.vpc_id
  logging_enabled          = false
  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "traefik", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count      = "1"
}

resource "aws_security_group" "alb" {
  name_prefix = "pod"
  description = "Security Group for pods run in the Fargate provider"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "alb_ingress_internet" {
  description       = "Allow pod access from the Internet."
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "alb_egress_internet" {
  description       = "Allow alb access to the anywhere."
  protocol          = "-1"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  type              = "egress"
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
		"portMappings": [{
			"containerPort": 80,
			"protocol": "tcp"
		}],
    "command": [
      "--api.insecure",
      "--accesslog",
      "--entrypoints.web.Address=:80",
      "--providers.kubernetesingress=true"
    ],
    "environment": [
      {
        "name": "KUBERNETES_SERVICE_HOST",
        "value": "${replace(aws_eks_cluster.eks.endpoint, "https://", "")}"
      },
      {
        "name": "KUBERNETES_SERVICE_PORT",
        "value": "443"
      }
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
 */
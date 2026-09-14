resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
# Create a private DNS namespace for service discovery
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "internal"
  description = "Private DNS namespace for ECS services"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "service" {
  for_each = var.services

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_cloudwatch_log_group" "service" {
  for_each = var.services

  name = "/ecs/${local.name_prefix}/${each.key}"

  retention_in_days = var.log_retention_days
}

resource "aws_ecs_task_definition" "service" {
  for_each                 = var.services
  family                   = "${local.name_prefix}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    merge({
      name      = each.key
      image     = each.value.image
      essential = true

      portMappings = [
        {
          containerPort = each.value.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for name, value in each.value.environment : {
          name  = name
          value = value
        }
      ]

      secrets = [
        for name, value in each.value.secrets : {
          name      = name
          valueFrom = value
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.service[each.key].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = each.key
        }
      }
      }, var.dockerhub_credentials_arn != null ? {
      repositoryCredentials = {
        credentialsParameter = var.dockerhub_credentials_arn
      }
    } : {})
  ])
}

# ECS service for each microservice defined in the services variable

resource "aws_ecs_service" "service" {
  for_each = var.services

  name = "${local.name_prefix}-${each.key}"

  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets = var.private_subnet_ids

    security_groups = [
      var.security_group_id
    ]

    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service[each.key].arn
  }

  dynamic "load_balancer" {
    for_each = each.key == "gateway" ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.gateway.arn
      container_name   = "gateway"
      container_port   = each.value.container_port
    }
  }
}

# create an Application Load Balancer for the ECS services
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.private_subnet_ids
}
resource "aws_lb_target_group" "gateway" {
  name        = "${local.name_prefix}-gateway"
  port        = var.services["gateway"].container_port
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {
    # /api/products
    # path     = "/"
    path = "/health"
    # path = "/api/movies"

    protocol = "HTTP"
    # protocol = "HTTP"
    matcher = "200"

    interval = 30
    timeout  = 5

    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# listeners for the Application Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      # port = "80"
      protocol = "HTTPS"
      # protocol         = "HTTP"
      status_code = "HTTP_301"
      # target_group_arn = aws_lb_target_group.gateway.arn

    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn

  port     = 443
  protocol = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway.arn
  }
}

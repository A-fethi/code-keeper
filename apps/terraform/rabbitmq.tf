resource "random_password" "rabbitmq" {
  length  = 20
  special = false
}

resource "aws_ssm_parameter" "rabbitmq_password" {
  name  = "/cloud-design/rabbitmq/password"
  type  = "SecureString"
  value = random_password.rabbitmq.result

  tags = {
    Name = "cloud-design-rabbitmq-password"
  }
}

resource "aws_cloudwatch_log_group" "rabbitmq" {
  name              = "/ecs/cloud-design/billing-queue"
  retention_in_days = 7

  tags = {
    Name = "cloud-design-rabbitmq-logs"
  }
}

resource "aws_service_discovery_service" "billing_queue" {
  name = "billing-queue"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "cloud-design-billing-queue-discovery"
  }
}

resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "cloud-design-billing-queue"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "billing-queue"
      image     = "${aws_ecr_repository.billing_queue.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5672
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "RABBITMQ_USER", value = "rabbitadmin" }
      ]

      secrets = [
        {
          name      = "RABBITMQ_PASSWORD"
          valueFrom = aws_ssm_parameter.rabbitmq_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.rabbitmq.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "billing-queue"
        }
      }
    }
  ])

  tags = {
    Name = "cloud-design-billing-queue-task"
  }
}

resource "aws_ecs_service" "rabbitmq" {
  name            = "cloud-design-billing-queue-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.queue.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.billing_queue.arn
  }

  tags = {
    Name = "cloud-design-billing-queue-service"
  }
}
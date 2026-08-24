resource "aws_ecs_task_definition" "gateway" {
  family                   = "cloud-design-gateway"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "api-gateway-app"
      image     = "${aws_ecr_repository.gateway.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "APIGATEWAY_PORT", value = "3000" },
        { name = "RABBITMQ_HOST", value = "billing-queue.cloud-design.local" },
        { name = "RABBITMQ_PORT", value = "5672" },
        { name = "RABBITMQ_USER", value = "rabbitadmin" },
        { name = "RABBITMQ_QUEUE", value = "billing-queue" },
        { name = "INVENTORY_APP_HOST", value = "inventory-app.cloud-design.local" },
        { name = "INVENTORY_APP_PORT", value = "8080" }
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
          "awslogs-group"         = aws_cloudwatch_log_group.gateway.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "gateway"
        }
      }
    }
  ])

  tags = {
    Name = "cloud-design-gateway-task"
  }
}
resource "aws_ecs_task_definition" "inventory_app" {
  family                   = "cloud-design-inventory-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "inventory-app"
      image     = "${aws_ecr_repository.inventory_app.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "INVENTORY_APP_PORT", value = "8080" },
        { name = "INVENTORY_DB_NAME", value = "inventory" },
        { name = "PYTHONUNBUFFERED", value = "1" },
        { name = "INVENTORY_DB_USER", value = "inventoryadmin" }
      ]

      secrets = [
        {
          name      = "INVENTORY_DB_PASSWORD"
          valueFrom = aws_ssm_parameter.inventory_db_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.inventory_app.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "inventory-app"
        }
      }
    }
  ])

  tags = {
    Name = "cloud-design-inventory-app-task"
  }
}
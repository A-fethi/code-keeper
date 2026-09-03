resource "aws_ecs_task_definition" "billing_app" {
  family                   = "cloud-design-billing-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "billing-app"
      image     = "${aws_ecr_repository.billing_app.repository_url}:latest"
      essential = true

      environment = [
        { name = "RABBITMQ_HOST", value = "billing-queue.cloud-design.local" },
        { name = "RABBITMQ_PORT", value = "5672" },
        { name = "RABBITMQ_QUEUE", value = "billing-queue" },
        { name = "BILLING_DB_NAME", value = "billing" },
        { name = "PYTHONUNBUFFERED", value = "1" },
        { name = "BILLING_DB_USER", value = "billingadmin" },
        { name = "RABBITMQ_USER", value = "rabbitadmin" }
      ]

      secrets = [
        {
          name      = "BILLING_DB_PASSWORD"
          valueFrom = aws_ssm_parameter.billing_db_password.arn
        },
        {
          name      = "RABBITMQ_PASSWORD"
          valueFrom = aws_ssm_parameter.rabbitmq_password.arn
        }
      ]     

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.billing_app.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "billing-app"
        }
      }
    }
  ])

  tags = {
    Name = "cloud-design-billing-app-task"
  }
}
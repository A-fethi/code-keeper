locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# IAM role for ECS tasks to pull private Docker images from Docker Hub

resource "aws_iam_role" "ecs_execution" {
  name = "${local.name_prefix}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AmazonECSTaskExecutionRolePolicy to the ECS execution role

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Secrets Manager secret for Docker Hub credentials :
# for ECS tasks to pull private Docker images from Docker Hub, we create 
# a secret in AWS Secrets Manager.

resource "aws_secretsmanager_secret" "dockerhub" {
  count = var.dockerhub_password != "" ? 1 : 0

  name = "${local.name_prefix}/dockerhub"

  tags = {
    Name = "${local.name_prefix}-dockerhub-secret"
  }
}
# Secrets Manager secret for Docker Hub credentials : 
# It will only be created if the dockerhub_password variable is provided.
# And the secret will be attached to the ECS execution role to allow ECS tasks 
# to access it.
resource "aws_secretsmanager_secret_version" "dockerhub" {
  count = var.dockerhub_password != "" ? 1 : 0

  secret_id = aws_secretsmanager_secret.dockerhub[0].id

  secret_string = jsonencode({
    username = var.dockerhub_username
    password = var.dockerhub_password
  })
}

# Allow ECS tasks to access the Docker Hub secret
resource "aws_iam_role_policy" "dockerhub_secret" {
  count = var.dockerhub_password != "" ? 1 : 0

  name = "${local.name_prefix}-dockerhub-secret-access"

  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_secretsmanager_secret.dockerhub[0].arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "application" {
  name                    = "${local.name_prefix}/application"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.name_prefix}-application-secret"
  }
}

resource "aws_secretsmanager_secret_version" "application" {
  secret_id     = aws_secretsmanager_secret.application.id
  secret_string = jsonencode(var.application_secrets)
}

resource "aws_iam_role_policy" "application_secrets" {
  name = "${local.name_prefix}-application-secret-access"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.application.arn
      }
    ]
  })
}

# resource "aws_iam_role_policy" "ecs_secrets_access" {
#   name = "code-keeper-ecs-secrets-access"
#   role = aws_iam_role.ecs_execution.id

#   policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [
#       {
#         Effect = "Allow"

#         Action = [
#           "ssm:GetParameter",
#           "ssm:GetParameters"
#         ]

#         Resource = [
#           var.inventory_db_password_arn,
#           var.billing_db_password_arn
#         ]
#       },
#       {
#         Effect = "Allow"

#         Action = [
#           "kms:Decrypt"
#         ]

#         Resource = [
#           data.aws_kms_key.ssm.arn
#         ]
#       }
#     ]
#   })
# }


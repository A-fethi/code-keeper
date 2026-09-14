output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"

  value = aws_iam_role.ecs_execution.arn
}

output "dockerhub_secret_arn" {
  description = "ARN of the Docker Hub secret"

  value = try(aws_secretsmanager_secret.dockerhub[0].arn, null)
}

output "application_secret_arn" {
  description = "ARN of the application credentials secret"
  value       = aws_secretsmanager_secret.application.arn
}

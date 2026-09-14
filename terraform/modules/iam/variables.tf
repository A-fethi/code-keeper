variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  sensitive   = true
}

variable "dockerhub_password" {
  description = "Docker Hub password"
  type        = string
  sensitive   = true
}

variable "application_secrets" {
  description = "Application credentials stored as JSON in Secrets Manager"
  type        = map(string)
  sensitive   = true
}


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

variable "inventory_db_password_arn" {
  description = "The ARN of the SSM parameter for the inventory database password"
  type        = string
}

variable "billing_db_password_arn" {
  description = "The ARN of the SSM parameter for the billing database password"
  type        = string 
}

# variable "aws_security_group" {
#   description = "The security group ID for the RDS instances"
#   type        = string
  
# }

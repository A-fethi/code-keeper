variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region used for ECS logging"
  type        = string
}

variable "vpc_id" {
  description = "VPC where ECS resources are deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group attached to ECS tasks"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM execution role ARN for ECS tasks"
  type        = string
}

variable "dockerhub_credentials_arn" {
  description = "Optional Secrets Manager ARN containing Docker Hub credentials"
  type        = string
  default     = null
}

# services

variable "services" {
  description = "Services deployed to ECS"

  type = map(object({
    type           = string
    image          = string
    container_port = number
    cpu            = number
    memory         = number
    desired_count  = number
    environment    = optional(map(string), {})
    secrets        = optional(map(string), {})
    autoscaling = optional(object({
      enabled      = bool
      min_capacity = number
      max_capacity = number
      cpu_target   = number
    }), null)
  }))
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}

variable "public_subnet_ids" {
  description = "Public subnets used by the Application Load Balancer"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener"
  type        = string
}
variable "alb_security_group_id" {
  description = "Security group attached to the Application Load Balancer"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Base name for the cloud resources"
  type        = string
  default     = "code-keeper"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}


variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.20.0/24"]
}

# services (added for ECS module)

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

  validation {
    condition = alltrue([
      for service in values(var.services) :
      service.container_port >= 1 && service.container_port <= 65535
      && service.cpu > 0
      && service.memory > 0
      && service.desired_count >= 0
    ])
    error_message = "Each service must have a valid container port, positive CPU and memory, and a non-negative desired count."
  }
}

####
variable "apigateway_port" {
  type        = number
  description = "Port exposed by the API Gateway"

  validation {
    condition     = var.apigateway_port >= 1 && var.apigateway_port <= 65535
    error_message = "apigateway_port must be between 1 and 65535."
  }
}

variable "inventory_app_port" {
  type        = number
  description = "Port exposed by the Inventory application"

  validation {
    condition     = var.inventory_app_port >= 1 && var.inventory_app_port <= 65535
    error_message = "inventory_app_port must be between 1 and 65535."
  }
}

variable "billing_app_port" {
  type        = number
  description = "Port exposed by the Billing application"

  validation {
    condition     = var.billing_app_port >= 1 && var.billing_app_port <= 65535
    error_message = "billing_app_port must be between 1 and 65535."
  }
}

variable "rabbitmq_port" {
  type        = number
  description = "Port used by RabbitMQ"

  validation {
    condition     = var.rabbitmq_port >= 1 && var.rabbitmq_port <= 65535
    error_message = "rabbitmq_port must be between 1 and 65535."
  }
}
variable "inventory_db_port" {
  type        = number
  description = "Port exposed by the Inventory database"

  validation {
    condition     = var.inventory_db_port >= 1 && var.inventory_db_port <= 65535
    error_message = "inventory_db_port must be between 1 and 65535."
  }
}

variable "billing_db_port" {
  type        = number
  description = "Port exposed by the Billing database"

  validation {
    condition     = var.billing_db_port >= 1 && var.billing_db_port <= 65535
    error_message = "billing_db_port must be between 1 and 65535."
  }
}


variable "inventory_db_user" {
  description = "Inventory database username"
  type        = string
  default     = "inventory_user"
}

variable "inventory_db_password" {
  description = "Inventory database password"
  type        = string
  sensitive   = true
  default     = "inventory_pass"
}

variable "inventory_db_name" {
  description = "Inventory database name"
  type        = string
  default     = "inventory_db"
}

variable "billing_db_user" {
  description = "Billing database username"
  type        = string
  default     = "billing_user"
}

variable "billing_db_password" {
  description = "Billing database password"
  type        = string
  sensitive   = true
  default     = "billing_pass"
}

variable "billing_db_name" {
  description = "Billing database name"
  type        = string
  default     = "billing_db"
}

variable "rabbitmq_user" {
  description = "RabbitMQ username"
  type        = string
  default     = "guest"
}

variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
  default     = "guest"
}

variable "dockerhub_username" {
  description = "Docker Hub username used for the deployed images"
  type        = string
  default     = "madagha"
  sensitive   = true
}

variable "dockerhub_password" {
  description = "Docker Hub password for authenticated pulls. Leave empty to use unauthenticated pulls."
  type        = string
  sensitive   = true
}

# certificate ARN for HTTPS listener
variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "backend_server_name" {
  description = "Backend server name for the API Gateway"
  type        = string
}

# variable "cognito_callback_urls" {
#   description = "cognito forwording url"
#   type = string
# }
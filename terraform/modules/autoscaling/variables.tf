variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

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

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_names" {
  type = map(string)
}

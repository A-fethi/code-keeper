variable "project_name" {
  type = string
}

variable "environment" {
  type = string
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
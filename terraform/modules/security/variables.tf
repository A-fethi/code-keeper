variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security groups will be created"
  type        = string
}

variable "gateway_port" {
  description = "Port used by the gateway service"
  type        = number
}

# variable "alb_security_group_id" {
#   description = "Security group attached to the Application Load Balancer"
#   type        = string
# }

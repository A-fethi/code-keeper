variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the API Gateway VPC Link"
  type        = list(string)
}

variable "vpc_link_security_group_id" {
  description = "Security group ID used by the API Gateway VPC Link"
  type        = string
}

variable "load_balancer_listener_arn" {
  description = "HTTPS listener ARN of the existing Application Load Balancer"
  type        = string
}

variable "cognito_issuer" {
  description = "Cognito User Pool issuer URL"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito User Pool client ID"
  type        = string
}
variable "backend_server_name" {
  description = "Backend server name for the API Gateway"
  type        = string
}

variable "aws_api_gateway_integration" {
  description = "Integration type for the API Gateway (HTTP_PROXY, AWS, MOCK, HTTP, or AWS_PROXY)"
  type        = string
  default     = "HTTP_PROXY"
}
variable "certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain"
  type        = string
}


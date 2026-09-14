variable "bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
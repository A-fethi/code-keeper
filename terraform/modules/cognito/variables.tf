variable "project_name" {
  description = "The name of the project for which the Cognito resources are being created."
  type        = string
}

variable "environment" {
  description = "The environment for which the Cognito resources are being created (e.g., dev, staging, prod)."
  type        = string
}
# variable "cognito_callback_urls" {
#   description = "OAuth callback URLs for the Cognito App Client"
#   type        = list(string)
# }

# variable "cognito_logout_urls" {
#   description = "OAuth logout URLs for the Cognito App Client"
#   type        = list(string)
# }

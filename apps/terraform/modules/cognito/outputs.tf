output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool issuer endpoint"
  value       = "https://${aws_cognito_user_pool.this.endpoint}"
}

output "client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.this.id
}

output "domain" {
  description = "Cognito hosted domain"
  value       = aws_cognito_user_pool_domain.this.domain
}

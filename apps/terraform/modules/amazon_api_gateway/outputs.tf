output "api_id" {
  description = "HTTP API ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "Default API Gateway endpoint"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "authorizer_id" {
  description = "Cognito JWT authorizer ID"
  value       = aws_apigatewayv2_authorizer.cognito.id
}

output "vpc_link_id" {
  description = "API Gateway VPC Link ID"
  value       = aws_apigatewayv2_vpc_link.main.id
}

output "custom_domain_target" {
  description = "Regional target hostname for the API Gateway custom domain"
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
}

output "custom_domain_hosted_zone_id" {
  description = "Route 53 hosted zone ID for the API Gateway custom domain"
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].hosted_zone_id
}

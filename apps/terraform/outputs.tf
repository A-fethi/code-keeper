output "alb_dns_name" {
  description = "Internal load balancer DNS name"
  value       = module.ecs.load_balancer_dns_name
}

output "api_gateway_endpoint" {
  description = "Public API Gateway endpoint"
  value       = module.amazon_api_gateway.api_endpoint
}

output "cluster_name" {
  description = "ECS cluster name"
  # value       = aws_ecs_cluster.main.name
  value = module.ecs.cluster_name
}

# output "service_names" {
#   description = "ECS service names"
#   value = {
#     for name, service in aws_ecs_service.service :
#     # for name, service in module.ecs.aws_ecs_service.service :
#     name => service.name
#   }
# }


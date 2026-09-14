output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_id" {
  description = "ID of the ECS cluster"

  value = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"

  value = aws_ecs_cluster.main.arn
}

output "service_names" {
  description = "Names of ECS services"

  value = {
    for name, service in aws_ecs_service.service :
    name => service.name
  }
}

# dns_name of the Application Load Balancer
output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_listener_arn" {
  description = "ARN of the Application Load Balancer listener"
  # value       = aws_lb_listener.main.arn
  value = aws_lb_listener.https.arn
}

output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb.id
}
output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = aws_security_group.ecs.id
}

# Api Gateway VPC Link security group ID
output "api_gateway_vpc_link_security_group_id" {
  description = "Security group ID for the API Gateway VPC Link"
  value       = aws_security_group.api_gateway_vpc_link.id
}

output "aws_security_group" {
  description = "Security group ID for the RDS instance"
  value       = aws_security_group.db.id
}

output "db_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = aws_security_group.db.id
}
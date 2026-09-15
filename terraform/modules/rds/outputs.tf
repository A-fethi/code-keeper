output "private_subnet_cidrs" {
  value       = var.private_subnet_cidrs
  description = "The list of private subnet CIDRs for the RDS instance"
}


output "inventory_db_user" {
  value       = local.inventory_username
  description = "The username for the inventory database"
}

output "billing_db_user" {
  value       = local.billing_username
  description = "The username for the billing database"
}

output "inventory_db_password" {
  value       = aws_ssm_parameter.inventory_db_password.value
  description = "The password for the inventory database"
}

output "billing_db_password" {
  value       = aws_ssm_parameter.billing_db_password.value
  description = "The password for the billing database"
}

output "inventory_db_password_arn" {
  value = aws_ssm_parameter.inventory_db_password.arn
}

output "billing_db_password_arn" {
  value = aws_ssm_parameter.billing_db_password.arn
}

output "inventory_db_host" {
  value       = aws_db_instance.inventory_db.address
  description = "The host for the inventory database"
}

output "billing_db_host" {
  value       = aws_db_instance.billing_db.address
  description = "The host for the billing database"
}

output "aws_ssm_parameter_inventory_db_password_arn" {
  value = aws_ssm_parameter.inventory_db_password.arn
}

output "aws_ssm_parameter_billing_db_password_arn" {
  value = aws_ssm_parameter.billing_db_password.arn
}
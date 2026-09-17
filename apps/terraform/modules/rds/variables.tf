variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the RDS instance will be created"
}

variable "environment" {
  type        = string
  description = "The environment for the RDS instance (e.g., dev, staging, prod)"
}



variable "private_subnet_cidrs" {
  type        = list(string)
  description = "A list of private subnet CIDRs for the RDS instance"
}
variable "aws_security_group" {
  type        = string
  description = "The ID of the security group to associate with the RDS instance"
}

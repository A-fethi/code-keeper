variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the RDS instance will be created"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "A list of private subnet CIDRs for the RDS instance"
}
variable "aws_security_group" {
  type = string
  description = "The ID of the security group to associate with the RDS instance"
}

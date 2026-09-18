locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ---------------------------------------------------------
# ALB Security Group
# ---------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS from API Gateway VPC Link"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway_vpc_link.id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}


# ---------------------------------------------------------
# ECS Security Group
# ---------------------------------------------------------


resource "aws_security_group" "ecs" {
  name        = "${local.name_prefix}-ecs-sg"
  description = "Security group for ECS services"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-ecs-sg"
  }
}

# resource "aws_security_group" "db" {
#   name        = "${local.name_prefix}-db-sg"
#   description = "Allow inbound only from ecs tier"
#   vpc_id      = var.vpc_id

#   ingress {
#     description     = "PostgreSQL from ecs tier only"
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${local.name_prefix}-db-sg"
#   }
# }


# Adding rules to assue the communication between the services and the ALB, as well as between the services themselves.
# rules of the security group for the Application Load Balancer
resource "aws_vpc_security_group_ingress_rule" "gateway_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.gateway_port
  to_port     = var.gateway_port
  ip_protocol = "tcp"

  description = "Allow ALB to reach Gateway"
}
# gateway → inventory
resource "aws_vpc_security_group_ingress_rule" "inventory_from_ecs" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.ecs.id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"

  description = "Allow ECS services to reach Inventory"
}

# rabbitmq
resource "aws_vpc_security_group_ingress_rule" "rabbitmq_from_ecs" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.ecs.id

  from_port   = 5672
  to_port     = 5672
  ip_protocol = "tcp"

  description = "Allow ECS services to reach RabbitMQ"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_ecs" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.ecs.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Allow ECS services to reach databases."
}

resource "aws_security_group" "api_gateway_vpc_link" {
  name        = "${local.name_prefix}-api-gateway-vpc-link"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-api-gateway-vpc-link"
  }
}

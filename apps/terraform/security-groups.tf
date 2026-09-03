# ALB - public facing
resource "aws_security_group" "alb" {
  name        = "cloud-design-alb-sg"
  description = "Allow inbound HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-design-alb-sg"
  }
}

# API Gateway app - only reachable from ALB
resource "aws_security_group" "gateway" {
  name        = "cloud-design-gateway-sg"
  description = "Allow inbound only from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "From ALB only"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-design-gateway-sg"
  }
}

# Inventory-app / billing-app - only reachable from gateway
resource "aws_security_group" "app" {
  name        = "cloud-design-app-sg"
  description = "Allow inbound only from API gateway"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "From gateway only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.gateway.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-design-app-sg"
  }
}

# Databases - only reachable from app tier
resource "aws_security_group" "db" {
  name        = "cloud-design-db-sg"
  description = "Allow inbound only from app tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from app tier only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-design-db-sg"
  }
}

# RabbitMQ queue - only reachable from app tier
resource "aws_security_group" "queue" {
  name        = "cloud-design-queue-sg"
  description = "Allow inbound only from app tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "AMQP from app tier only"
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description     = "AMQP from gateway"
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.gateway.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-design-queue-sg"
  }
}
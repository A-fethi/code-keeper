# Terraform module for creating an RDS instance

# Create a private DNS namespace for service discovery
# resource "aws_service_discovery_private_dns_namespace" "main" {
  # name        = "internal"
  # description = "Private DNS namespace for ECS services"
  # vpc         = var.vpc_id
# }
# 


# inventory-db

resource "aws_db_subnet_group" "main" {
  name       = "cloud-design-db-subnet-group"
  # subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  subnet_ids = var.private_subnet_cidrs

  tags = {
    Name = "cloud-design-db-subnet-group"
  }
}

resource "random_password" "inventory_db" {
  length  = 20
  special = false
}

resource "aws_ssm_parameter" "inventory_db_password" {
  name  = "/cloud-design/inventory-db/password"
  type  = "SecureString"
  value = random_password.inventory_db.result

  tags = {
    Name = "cloud-design-inventory-db-password"
  }
}

resource "aws_db_instance" "inventory_db" {
  identifier     = "cloud-design-inventory-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "inventory"
  username = "inventoryadmin"
  password = random_password.inventory_db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.aws_security_group]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true

  backup_retention_period = 1

  tags = {
    Name = "cloud-design-inventory-db"
  }
}
# billing-db

resource "random_password" "billing_db" {
  length  = 20
  special = false
}

resource "aws_ssm_parameter" "billing_db_password" {
  name  = "/cloud-design/billing-db/password"
  type  = "SecureString"
  value = random_password.billing_db.result

  tags = {
    Name = "cloud-design-billing-db-password"
  }
}

resource "aws_db_instance" "billing_db" {
  identifier     = "cloud-design-billing-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "billing"
  username = "billingadmin"
  password = random_password.billing_db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.aws_security_group]

  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 1

  tags = {
    Name = "cloud-design-billing-db"
  }
}

# resource "aws_service_discovery_service" "billing_db" {
#   name = "billing-db"

#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.main.id

#     dns_records {
#       ttl  = 10
#       type = "CNAME"
#     }

#     routing_policy = "WEIGHTED"
#   }

#   tags = {
#     Name = "cloud-design-billing-db-discovery"
#   }
# }

# resource "aws_service_discovery_instance" "billing_db" {
#   instance_id = "billing-db-rds"
#   service_id  = aws_service_discovery_service.billing_db.id

#   attributes = {
#     AWS_INSTANCE_CNAME = aws_db_instance.billing_db.address
#   }
# }

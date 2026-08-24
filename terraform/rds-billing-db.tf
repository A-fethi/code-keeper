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
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az             = false
  publicly_accessible  = false
  skip_final_snapshot  = true
  backup_retention_period = 1

  tags = {
    Name = "cloud-design-billing-db"
  }
}

resource "aws_service_discovery_service" "billing_db" {
  name = "billing-db"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "CNAME"
    }

    routing_policy = "WEIGHTED"
  }

  tags = {
    Name = "cloud-design-billing-db-discovery"
  }
}

resource "aws_service_discovery_instance" "billing_db" {
  instance_id = "billing-db-rds"
  service_id  = aws_service_discovery_service.billing_db.id

  attributes = {
    AWS_INSTANCE_CNAME = aws_db_instance.billing_db.address
  }
}
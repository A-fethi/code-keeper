resource "aws_db_subnet_group" "main" {
  name       = "cloud-design-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

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
  overwrite = true

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
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot  = true

  backup_retention_period = 1

  tags = {
    Name = "cloud-design-inventory-db"
  }
}
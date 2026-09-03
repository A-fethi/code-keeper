resource "aws_ecr_repository" "gateway" {
  name                 = "cloud-design/api-gateway-app"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cloud-design-gateway-ecr"
  }
}

resource "aws_ecr_repository" "billing_app" {
  name                 = "cloud-design/billing-app"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cloud-design-billing-app-ecr"
  }
}

resource "aws_ecr_repository" "billing_db" {
  name                 = "cloud-design/billing-db"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cloud-design-billing-db-ecr"
  }
}

resource "aws_ecr_repository" "billing_queue" {
  name                 = "cloud-design/billing-queue"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cloud-design-billing-queue-ecr"
  }
}

resource "aws_ecr_repository" "inventory_app" {
  name                 = "cloud-design/inventory-app"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cloud-design-inventory-app-ecr"
  }
}

resource "aws_ecr_repository" "inventory_db" {
  name                 = "cloud-design/inventory-db"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "cloud-design-inventory-db-ecr"
  }
}
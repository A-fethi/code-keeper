locals {
  ecr_services = {
    for name, service in var.services :
    name => service
    if contains(["gateway", "billing", "inventory"], name)
  }
}

resource "aws_ecr_repository" "service" {

  for_each = var.environment == "staging" ? local.ecr_services : {}

  # lifecycle {
  #   prevent_destroy = true
  # }

  # for_each = local.ecr_services

  name = "${var.project_name}/${each.key}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

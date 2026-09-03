resource "aws_service_discovery_private_dns_namespace" "internal" {
  name = "cloud-design.local"
  vpc  = aws_vpc.main.id

  tags = {
    Name = "cloud-design-namespace"
  }
}

resource "aws_service_discovery_service" "inventory_app" {
  name = "inventory-app"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "cloud-design-inventory-app-discovery"
  }
}
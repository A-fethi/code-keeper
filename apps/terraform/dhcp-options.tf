resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "cloud-design.local"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "cloud-design-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_service_discovery_service" "inventory_db" {
  name = "inventory-db"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "CNAME"
    }

    routing_policy = "WEIGHTED"
  }

  tags = {
    Name = "cloud-design-inventory-db-discovery"
  }
}

resource "aws_service_discovery_instance" "inventory_db" {
  instance_id = "inventory-db-rds"
  service_id  = aws_service_discovery_service.inventory_db.id

  attributes = {
    AWS_INSTANCE_CNAME = aws_db_instance.inventory_db.address
  }
}
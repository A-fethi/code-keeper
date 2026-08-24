resource "aws_cloudwatch_log_group" "inventory_app" {
  name              = "/ecs/cloud-design/inventory-app"
  retention_in_days = 7

  tags = {
    Name = "cloud-design-inventory-app-logs"
  }
}
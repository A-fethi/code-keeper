resource "aws_cloudwatch_log_group" "gateway" {
  name              = "/ecs/cloud-design/api-gateway-app"
  retention_in_days = 7

  tags = {
    Name = "cloud-design-gateway-logs"
  }
}
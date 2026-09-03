resource "aws_cloudwatch_log_group" "billing_app" {
  name              = "/ecs/cloud-design/billing-app"
  retention_in_days = 7

  tags = {
    Name = "cloud-design-billing-app-logs"
  }
}
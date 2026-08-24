resource "aws_ecs_cluster" "main" {
  name = "cloud-design-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"  # keep disabled for now — this has its own cost, we can enable later if needed
  }

  tags = {
    Name = "cloud-design-cluster"
  }
}
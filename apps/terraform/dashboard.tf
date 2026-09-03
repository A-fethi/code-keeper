resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "cloud-design-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "Gateway CPU Utilization"
          view  = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "cloud-design-gateway-service", "ClusterName", "cloud-design-cluster"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count & Response Time"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Target Health"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_lb_target_group.gateway.arn_suffix, "LoadBalancer", aws_lb.main.arn_suffix],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", aws_lb_target_group.gateway.arn_suffix, "LoadBalancer", aws_lb.main.arn_suffix]
          ]
        }
      },
      {
          type   = "log"
          x      = 12
          y      = 6
          width  = 12
          height = 6
          properties = {
            title  = "Gateway Recent Logs"
            region = "us-east-1"
            view   = "table"
            query  = "SOURCE '/ecs/cloud-design/api-gateway-app' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          }
        }
    ]
  })
}
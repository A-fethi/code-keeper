
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  autoscaling_services = {
    for name, service in var.services :
    name => service
    if contains(["gateway", "inventory", "billing"], name)
    && service.autoscaling != null
    && service.autoscaling.enabled
  }
}
# ECS services autoscalling (target)

resource "aws_appautoscaling_target" "ecs_service" {

  for_each = local.autoscaling_services

  resource_id = "service/${var.ecs_cluster_name}/${var.ecs_service_names[each.key]}"

  # We are scaling the number of ECS tasks.
  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"

  # These values come directly from:
  ### services.<service>.autoscaling

  min_capacity = each.value.autoscaling.min_capacity
  max_capacity = each.value.autoscaling.max_capacity
}

# ECS services autoscalling (policy)

resource "aws_appautoscaling_policy" "cpu" {

  for_each = local.autoscaling_services

  name = "${local.name_prefix}-${each.key}-cpu"

  policy_type = "TargetTrackingScaling"

  resource_id = aws_appautoscaling_target.ecs_service[each.key].resource_id

  scalable_dimension = aws_appautoscaling_target.ecs_service[each.key].scalable_dimension

  service_namespace = aws_appautoscaling_target.ecs_service[each.key].service_namespace

  target_tracking_scaling_policy_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = each.value.autoscaling.cpu_target

    # Wait at least 60 seconds before another scale-in
    # decision.
    scale_in_cooldown = 60

    # Wait at least 60 seconds before another scale-out
    # decision.
    scale_out_cooldown = 60
  }
}





# resource "aws_appautoscaling_target" "api_gateway" {
#   max_capacity       = 4
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api_gateway.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# resource "aws_appautoscaling_policy" "api_gateway_cpu" {
#   name               = "${local.name_prefix}-api-gateway-cpu"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.api_gateway.resource_id
#   scalable_dimension = aws_appautoscaling_target.api_gateway.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.api_gateway.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value       = 50.0
#     scale_in_cooldown  = 60
#     scale_out_cooldown = 60
#   }
# }

# resource "aws_appautoscaling_target" "inventory_app" {
#   max_capacity       = 4
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.inventory_app.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# resource "aws_appautoscaling_policy" "inventory_app_cpu" {
#   name               = "${local.name_prefix}-inventory-app-cpu"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.inventory_app.resource_id
#   scalable_dimension = aws_appautoscaling_target.inventory_app.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.inventory_app.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value       = 50.0
#     scale_in_cooldown  = 60
#     scale_out_cooldown = 60
#   }
# }

# resource "aws_appautoscaling_target" "billing_app" {
#   max_capacity       = 4
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.billing_app.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# resource "aws_appautoscaling_policy" "billing_app_cpu" {
#   name               = "${local.name_prefix}-billing-app-cpu"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.billing_app.resource_id
#   scalable_dimension = aws_appautoscaling_target.billing_app.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.billing_app.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     target_value       = 50.0
#     scale_in_cooldown  = 60
#     scale_out_cooldown = 60
#   }
# }

###
# Auto Scaling Group (asg)
# This section creates a highly available/scalable instance group in an aws region/zone.
#
# Purpose:
#         The asg defines the configuration for instances used with the target Auto Scaling Group (asg)
###

###
# Autoscaling group with launch template
###

resource "aws_autoscaling_group" "aws_asg_lt" {
  count = var.create_asg ? 1 : 0

  name_prefix = "${join(
    "-",
    compact(
      [
        coalesce(var.asg_name, var.prefix),
        # var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, [""]), 0) : "",
      ],
    ),
  )}-"
  service_linked_role_arn   = var.service_linked_role_arn
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  default_cooldown          = var.default_cooldown
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes

  # placement contraint arguments
  vpc_zone_identifier = var.vpc_zone_identifier
  placement_group     = var.placement_group

  # loadbalancing option of the asg
  # for elbs use the load_balancers argument
  # for albs use the target_group_arns
  load_balancers        = var.load_balancers
  target_group_arns     = var.target_group_arns
  wait_for_elb_capacity = var.wait_for_elb_capacity

  enabled_metrics = var.enabled_metrics
  # metrics_granularity  has a single default value of '1Minute'
  # it is paired with the list of metrics enabled from the enabled_metrics argument
  # need to test this with a single metric to see if it is needed
  metrics_granularity = var.metrics_granularity

  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = var.create_lt ? element(concat(aws_launch_template.aws_lt.*.id, [""]), 0) : var.launch_template
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_types_lt
        content {
          instance_type     = lookup(override.value, "instance_type", null)
          weighted_capacity = lookup(override.value, "weighted_capacity", null)
        }
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = var.spot_allocation_strategy
      spot_instance_pools                      = var.spot_allocation_strategy == "lowest-price" ? var.spot_instance_pools : null
      spot_max_price                           = var.spot_price
    }
  }

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = var.prefix
        "propagate_at_launch" = true
      },
    ],
    var.tags,
    local.tags_asg_format,
  )

  lifecycle {
    create_before_destroy = true
  }
}


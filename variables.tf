###
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
###

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

###
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
###

# global resource parameters
variable "prefix" {
  description = "Creates a unique name beginning with the specified prefix"
}

# control flags
variable "create_asg" {
  description = "Whether to create autoscaling group"
  type        = bool
  # default     = true
}

variable "create_lt" {
  description = "Whether to create launch template"
  type        = bool
  # default     = false
}

# Auto Scaling Group (required)
variable "asg_name" {
  description = "Creates a unique name for autoscaling group beginning with the specified prefix"
  type        = string
  default     = ""
}

variable "max_size" {
  description = "The maximum size of the auto scale group"
  type        = string
}

variable "min_size" {
  description = "The minimum size of the auto scale group"
  type        = string
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = string
}

variable "health_check_type" {
  description = "Controls how health checking is done. Values are - EC2 and ELB"
  type        = string
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}


# Launch template (required)
variable "image_id" {
  description = "The EC2 image ID to launch"
  type        = string
  default     = ""
}

variable "image_filter" {
  description = "The EC2 image ID to launch"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}

variable "image_owner" {
  description = "The EC2 image ID to launch"
  type        = string
  default     = "099720109477"
}

###
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
###

# Auto Scaling Group (optional)
variable "service_linked_role_arn" {
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services."
  type        = string
  default     = ""
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  type        = number
  default     = 300
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default"
  type        = list(string)
  default     = ["Default"]
}

variable "suspended_processes" {
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer. Note that if you suspend either the Launch or Terminate process types, it can prevent your autoscaling group from functioning properly."
  type        = list(string)
  default     = []
}

variable "placement_group" {
  description = "The name of the placement group into which you'll launch your instances, if any"
  type        = string
  default     = ""
}

variable "load_balancers" {
  description = "A list of elastic load balancer names to add to the autoscaling group names"
  type        = list(string)
  default     = []
}

variable "target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  type        = list(string)
  default     = []
}

variable "wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over min_elb_capacity behavior."
  type        = number
  default     = null
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances"
  type        = list(string)
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute"
  type        = string
  default     = "1Minute"
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = string
  default     = "10m"
}

variable "tags" {
  description = "A list of tag blocks. Each element should have keys named key, value, and propagate_at_launch."
  type        = list(map(string))
  default     = []
}

variable "tags_as_map" {
  description = "A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws_autoscaling_group requires."
  type        = map(string)
  default     = {}
}

# Placement Group (optional)
variable "create_pg" {
  description = "Whether to create launch configuration"
  type        = bool
  default     = false
}

variable "on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
  type        = number
  default     = 0
}

variable "on_demand_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity."
  type        = number
  default     = 100
}

variable "spot_allocation_strategy" {
  description = "How to allocate capacity across the Spot pools. Valid values: 'lowest-price', 'capacity-optimized'."
  type        = string
  default     = "capacity-optimized"
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify. Diversifies your Spot capacity across multiple instance types to find the best pricing."
  type        = number
  default     = 2
}

# Launch Template (optional)
variable "instance_types_lt" {
  description = "Instance types to launch, minimum 2 types must be specified. List of Map of 'instance_type'(required) and 'weighted_capacity'(optional)."
  type        = list(map(any))
  default     = [{}]
}

variable "block_device_mappings" {
  description = "Mappings of block devices, see https://www.terraform.io/docs/providers/aws/r/launch_template.html#block-devices"
  type        = list(any)
  default     = [{}]
}

# variable "network_interfaces" {
#   description = "Customize details about the network interfaces of the instance"
#   type = list(map(string))
#   default =
# }

###
# Launch Template (lt)
# This section creates an immutable launch template.
#
# Purpose:
#         The lt defines the configuration for instances used with the target Auto Scaling Group (asg)
###

resource "aws_launch_template" "aws_lt" {
  count = var.create_lt ? 1 : 0

  name_prefix          = "${coalesce(var.lt_name, var.prefix)}-"
  image_id             = var.image_id != "" ? var.image_id : data.aws_ami.launch_lt_ami.image_id
  instance_type        = var.instance_type_lt != "" ? var.instance_type_lt : ""
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name != "" ? var.key_name : tls_private_key.kp.private_key_pem
  security_groups      = var.security_groups
  user_data            = base64encode(var.user_data)
  enable_monitoring    = var.enable_monitoring
  ebs_optimized        = var.ebs_optimized

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", [])
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          iops                  = lookup(ebs.value, "iops", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }

  network_interfaces {
    description                 = coalesce(var.lt_name, var.name)
    device_index                = 0
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_groups
  }

  lifecycle {
    create_before_destroy = true
  }
}

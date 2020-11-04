###
# Placement Group (pg)
# This section creates a placement group to guide the EC2 services scheduling of instances.
#
# Purpose:
#         The pg defines a strategy to influence the placement of a group of interdependent instances to meet the needs of your workload.
###
resource "aws_placement_group" "aws_pg" {
  count = var.create_pg ? 1 : 0

  name     = "hunky-dory-pg"
  strategy = "cluster"
}

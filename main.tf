
###
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
###

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = "~> 2.41"
  }
}

###
# REQUIRES A SPECIFIC AWS PROVIDER VERSION OR HIGHER
# This module has been tested with 2.0+ of the provider and may not be compatible with older versions.
###

# provider "aws" {
#   version = "~> 2.41"
# }

data "aws_ami" "launch_cfg_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.image_filter}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${var.image_owner}"] # Canonical
}

resource tls_private_key "kp" {
  algorithm = "RSA"
}

resource aws_key_pair "kp" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.kp.public_key_openssh
}

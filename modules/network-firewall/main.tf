locals {
  metadata = {
    package = "terraform-aws-firewall"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# Network Firewall
###################################################

resource "aws_networkfirewall_firewall" "this" {
  name        = var.name
  description = var.description

  firewall_policy_arn = asdf

  vpc_id = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = local.enabled_network_mapping

    content {
      subnet_id = subnet_mapping.value.subnet_id
    }
  }

  subnet_change_protection          = var.subnet_change_protection_enabled
  firewall_policy_change_protection = var.firewall_policy_change_protection_enabled
  deletion_protection               = var.deletion_protection_enabled

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Logging Configurations
###################################################

resource "aws_networkfirewall_logging_configuration" "this" {
  count = var.value != null ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.this.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        deliveryStream = aws_kinesis_firehose_delivery_stream.example.name
      }
      log_destination_type = "KinesisDataFirehose"
      log_type             = "ALERT"
    }
  }
}

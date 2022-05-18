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
# Rule Group for DNS Firewall
###################################################

resource "aws_route53_resolver_firewall_rule_group" "this" {
  name = var.name
  # description = var.description

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Rules for DNS Firewall Rule Group
###################################################

# resource "aws_route53_resolver_firewall_rule" "this" {
#   count = var.value != null ? 1 : 0
#
#   firewall_arn = aws_route53_resolver_firewall_rule_group.this.arn
#
#   logging_configuration {
#     log_destination_config {
#       log_destination = {
#         deliveryStream = aws_kinesis_firehose_delivery_stream.example.name
#       }
#       log_destination_type = "KinesisDataFirehose"
#       log_type             = "ALERT"
#     }
#   }
# }

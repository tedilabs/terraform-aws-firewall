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
# REGEX Pattern Set for WAF (Web Application Firewall)
###################################################

resource "aws_wafv2_regex_pattern_set" "this" {
  region = var.region

  name        = var.name
  description = var.description

  scope = var.is_global ? "CLOUDFRONT" : "REGIONAL"

  dynamic "regular_expression" {
    for_each = var.regex_patterns
    iterator = pattern

    content {
      regex_string = pattern.value
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}

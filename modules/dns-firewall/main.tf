locals {
  metadata = {
    package = "terraform-aws-firewall"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.target.id
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

data "aws_region" "this" {
  region = var.region
}


###################################################
# DNS Firewall Configuration for VPC
###################################################

resource "aws_route53_resolver_firewall_config" "this" {
  count = var.target.type == "VPC" ? 1 : 0

  region = var.region

  resource_id = var.target.id

  firewall_fail_open = (var.target.type == "VPC" && var.fail_open_enabled) ? "ENABLED" : "DISABLED"
}


###################################################
# Rule Group Associations with VPC
###################################################

resource "aws_route53_resolver_firewall_rule_group_association" "this" {
  for_each = {
    for rule_group in var.rule_groups :
    rule_group.name => rule_group
    if var.target.type == "VPC"
  }

  region = var.region

  vpc_id = var.target.id

  name                   = each.key
  priority               = each.value.priority
  firewall_rule_group_id = each.value.id

  mutation_protection = (var.target.type == "VPC" && each.value.mutation_protection_enabled) ? "ENABLED" : "DISABLED"

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Rule Group Associations with Route53 Profile
###################################################

data "aws_route53_resolver_firewall_rule_group" "this" {
  for_each = {
    for rule_group in var.rule_groups :
    rule_group.name => rule_group
    if var.target.type == "ROUTE53_PROFILE"
  }

  region = var.region

  firewall_rule_group_id = each.value.id
}

resource "aws_route53profiles_resource_association" "this" {
  for_each = {
    for rule_group in var.rule_groups :
    rule_group.name => rule_group
    if var.target.type == "ROUTE53_PROFILE"
  }

  region = var.region

  profile_id = var.target.id

  name         = each.key
  resource_arn = data.aws_route53_resolver_firewall_rule_group.this[each.key].arn
  resource_properties = jsonencode({
    priority = each.value.priority
  })
}

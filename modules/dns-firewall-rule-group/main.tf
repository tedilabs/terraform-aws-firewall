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
  region = var.region

  name = var.name

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

resource "aws_route53_resolver_firewall_rule" "this" {
  for_each = {
    for rule in var.rules :
    rule.priority => rule
  }

  region = var.region

  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.this.id

  priority = each.key
  name     = each.value.name

  firewall_domain_list_id = each.value.domain_list
  dns_threat_protection   = try(each.value.threat_protection.type, null)
  confidence_threshold    = try(each.value.threat_protection.confidence_threshold, null)

  q_type                             = each.value.query_type
  firewall_domain_redirection_action = "${each.value.dns_redirection_chain_inspection_mode}_REDIRECTION_DOMAIN"

  action = each.value.action
  block_response = (each.value.action == "BLOCK"
    ? each.value.action_parameters.response
    : null
  )
  block_override_domain = (each.value.action_parameters.response == "OVERRIDE"
    ? each.value.action_parameters.override.value
    : null
  )
  block_override_dns_type = (each.value.action_parameters.response == "OVERRIDE"
    ? each.value.action_parameters.override.type
    : null
  )
  block_override_ttl = (each.value.action_parameters.response == "OVERRIDE"
    ? each.value.action_parameters.override.ttl
    : null
  )
}

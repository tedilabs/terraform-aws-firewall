output "region" {
  description = "The AWS region this module resources resides in."
  value       = data.aws_region.this.region
}

output "target" {
  description = <<EOF
  The target which the DNS Firewall rule groups are associated with.
    `type` - The type of the target. Either `VPC` or `ROUTE53_PROFILE`.
    `id` - The ID of the target.
  EOF
  value = {
    type = var.target.type
    id   = var.target.id
  }
}

output "fail_open_enabled" {
  description = "Whether the Route53 Resolver handles queries during failures. Only available when `target.type` is `VPC`."
  value = (var.target.type == "VPC"
    ? one(aws_route53_resolver_firewall_config.this[*].firewall_fail_open) == "ENABLED"
    : null
  )
}

output "rule_groups" {
  description = <<EOF
  The configuration of rule groups associated with the target. Each value of `rule_groups` is keyed by the priority of the rule group association as defined below.
    `id` - The ID of the firewall rule group.
    `name` - The name of the association.
    `priority` - The processing order of the rule group among the rule groups associated with the target.
    `mutation_protection_enabled` - Whether the modification or removal of the association is disallowed.
    `association` - The information of the rule group association resource. `association` as defined below.
      `arn` - The ARN of the firewall rule group association. Only available when `target.type` is `VPC`.
      `id` - The ID of the firewall rule group association.
  EOF
  value = {
    for rule_group in var.rule_groups :
    rule_group.priority => {
      id       = rule_group.id
      name     = rule_group.name
      priority = rule_group.priority

      mutation_protection_enabled = var.target.type == "VPC" && rule_group.mutation_protection_enabled

      association = (var.target.type == "VPC"
        ? {
          arn = aws_route53_resolver_firewall_rule_group_association.this[rule_group.name].arn
          id  = aws_route53_resolver_firewall_rule_group_association.this[rule_group.name].id
        }
        : {
          arn = null
          id  = aws_route53profiles_resource_association.this[rule_group.name].id
        }
      )
    }
  }
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

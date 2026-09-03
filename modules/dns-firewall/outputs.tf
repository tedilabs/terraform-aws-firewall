output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_route53_resolver_firewall_config.this.region
}

output "id" {
  description = "The ID of the firewall configuration."
  value       = aws_route53_resolver_firewall_config.this.id
}

output "vpc_id" {
  description = "The VPC ID which the firewall applies to."
  value       = aws_route53_resolver_firewall_config.this.resource_id
}

output "owner_id" {
  description = "The AWS Account ID of the owner of the VPC that this firewall applies to."
  value       = aws_route53_resolver_firewall_config.this.owner_id
}

output "fail_open_enabled" {
  description = "Whether the Route53 Resolver handles queries during failures."
  value       = aws_route53_resolver_firewall_config.this.firewall_fail_open == "ENABLED"
}

output "rule_groups" {
  description = <<EOF
  The configuration of rule groups associated with the firewall. Each value of `rule_groups` is keyed by the priority of the rule group association as defined below.
    `id` - The ID of the firewall rule group.
    `name` - The name of the association.
    `priority` - The processing order of the rule group among the rule groups associated with the VPC.
    `mutation_protection_enabled` - Whether the modification or removal of the association is disallowed.
    `association` - The information of the rule group association resource. `association` as defined below.
      `arn` - The ARN of the firewall rule group association.
      `id` - The ID of the firewall rule group association.
  EOF
  value = {
    for rule_group in aws_route53_resolver_firewall_rule_group_association.this :
    rule_group.priority => {
      id       = rule_group.firewall_rule_group_id
      name     = rule_group.name
      priority = rule_group.priority

      mutation_protection_enabled = rule_group.mutation_protection == "ENABLED"

      association = {
        arn = rule_group.arn
        id  = rule_group.id
      }
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

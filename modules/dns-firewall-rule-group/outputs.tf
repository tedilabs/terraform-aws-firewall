output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_route53_resolver_firewall_rule_group.this.region
}

output "arn" {
  description = "The ARN of the firewall rule group."
  value       = aws_route53_resolver_firewall_rule_group.this.arn
}

output "id" {
  description = "The ID of the firewall rule group."
  value       = aws_route53_resolver_firewall_rule_group.this.id
}

output "owner_id" {
  description = "The AWS Account ID for the account that created the rule group."
  value       = aws_route53_resolver_firewall_rule_group.this.owner_id
}

output "name" {
  description = "The name of the firewall rule group."
  value       = aws_route53_resolver_firewall_rule_group.this.name
}

# output "description" {
#   description = "The description of the firewall rule group."
#   value       = aws_route53_resolver_firewall_rule_group.this.description
# }

output "rules" {
  description = <<EOF
  The rules of the firewall rule group. Each value of `rules` is keyed by the priority of the rule as defined below.
    `id` - The ID of the rule.
    `name` - The name of the rule.
    `domain_list` - The ID of the domain list which is used in the rule. Only set for standard rules.
    `threat_protection` - The configuration of the DNS Firewall Advanced rule. Only set for DNS Firewall Advanced rules.
    `query_type` - The DNS query type which the rule evaluates.
    `dns_redirection_chain_inspection_mode` - How the rule evaluates the DNS redirection in the DNS redirection chain.
    `action` - The action which DNS Firewall takes on a matched DNS query.
    `action_parameters` - The parameters of the rule action.
  EOF
  value = {
    for priority, rule in aws_route53_resolver_firewall_rule.this :
    priority => {
      id   = rule.id
      name = rule.name
      # description = rule.description
      domain_list = rule.firewall_domain_list_id
      threat_protection = (rule.dns_threat_protection != null
        ? {
          id                   = rule.firewall_threat_protection_id
          type                 = rule.dns_threat_protection
          confidence_threshold = rule.confidence_threshold
        }
        : null
      )

      query_type                            = rule.q_type
      dns_redirection_chain_inspection_mode = trimsuffix(rule.firewall_domain_redirection_action, "_REDIRECTION_DOMAIN")

      action = rule.action
      action_parameters = try({
        "BLOCK" = {
          response = rule.block_response
          override = (rule.block_response == "OVERRIDE"
            ? {
              type  = rule.block_override_dns_type
              value = rule.block_override_domain
              ttl   = rule.block_override_ttl
            }
          : null)
        }
      }[rule.action], {})
    }
  }
}

output "profile_associations" {
  description = <<EOF
  A list of Route53 Profile associations with the firewall rule group. Each value of `profile_associations` as defined below.
    `id` - The ID of the Route53 Profile resource association.
    `name` - The name of the Route53 Profile resource association.
    `owner_id` - The AWS Account ID of the owner of the Route53 Profile resource association.
    `status` - The status of the Route53 Profile resource association.
    `profile` - The information of the associated Route53 Profile. `profile` as defined below.
      `id` - The ID of the Route53 Profile.
      `region` - The AWS region which the Route53 Profile resource association resides in.
    `resource` - The information of the associated resource. `resource` as defined below.
      `type` - The type of the associated resource.
      `arn` - The ARN of the associated resource.
      `properties` - The properties of the associated resource.
  EOF
  value = [
    for association in aws_route53profiles_resource_association.this : {
      id       = association.id
      name     = association.name
      owner_id = association.owner_id
      status   = association.status
      profile = {
        id     = association.profile_id
        region = association.region
      }
      resource = {
        type       = association.resource_type
        arn        = association.resource_arn
        properties = association.resource_properties
      }
    }
  ]
}

output "sharing" {
  description = <<EOF
  The configuration for sharing of the Route53 Resolver DNS Firewall Rule Group.
    `status` - An indication of whether the rule group is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.
    `shares` - The list of resource shares via RAM (Resource Access Manager).
  EOF
  value = {
    status = aws_route53_resolver_firewall_rule_group.this.share_status
    shares = module.share
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

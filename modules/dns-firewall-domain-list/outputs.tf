output "region" {
  description = "The AWS region this module resources resides in."
  value       = local.domain_list.region
}

output "arn" {
  description = "The ARN of the domain list."
  value       = local.domain_list.arn
}

output "id" {
  description = "The ID of the domain list."
  value       = local.domain_list.id
}

output "name" {
  description = "The name of the domain list."
  value       = local.domain_list.name
}

output "domains" {
  description = "The set of domains from the firewall domain list. Always empty if `type` is `MANAGED`, because AWS does not disclose the domains of its managed domain lists."
  value       = local.domain_list.domains
}

output "domain_count" {
  description = "The number of domains in the firewall domain list. Unlike `domains`, this is also populated if `type` is `MANAGED`."
  value       = local.domain_list.domain_count
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = local.resource_group_enabled
    },
    (local.resource_group_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

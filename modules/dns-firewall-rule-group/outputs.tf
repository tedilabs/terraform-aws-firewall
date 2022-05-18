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

output "share_status" {
  description = "Whether the rule group is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Valid values: `NOT_SHARED`, `SHARED_BY_ME`, `SHARED_WITH_ME`."
  value       = aws_route53_resolver_firewall_rule_group.this.share_status
}

output "name" {
  description = "The name of the firewall rule group."
  value       = aws_route53_resolver_firewall_rule_group.this.name
}

# output "description" {
#   description = "The description of the firewall rule group."
#   value       = aws_route53_resolver_firewall_rule_group.this.description
# }

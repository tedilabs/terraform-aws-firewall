output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_wafv2_regex_pattern_set.this.region
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the regular expression pattern set."
  value       = aws_wafv2_regex_pattern_set.this.arn
}

output "id" {
  description = "The ID of the regular expression pattern set."
  value       = aws_wafv2_regex_pattern_set.this.id
}

output "name" {
  description = "The name of the regular expression pattern set."
  value       = aws_wafv2_regex_pattern_set.this.name
}

output "description" {
  description = "The description of the regular expression pattern set."
  value       = aws_wafv2_regex_pattern_set.this.description
}

output "is_global" {
  description = "Whether this is for a global application(AWS CloudFront distribution) or for a regional application."
  value       = aws_wafv2_regex_pattern_set.this.scope == "CLOUDFRONT"
}

output "regex_patterns" {
  description = "A set of regular expressions for the regex pattern set."
  value       = aws_wafv2_regex_pattern_set.this.regular_expression[*].regex_string
}

output "lock_token" {
  description = "The lock token used for optimistic locking."
  value       = aws_wafv2_regex_pattern_set.this.lock_token
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

# output "debug" {
#   value = {
#     for k, v in aws_wafv2_regex_pattern_set.this :
#     k => v
#     if !contains(["arn", "id", "name", "name_prefix", "description", "scope", "regular_expression", "region", "tags", "tags_all", "lock_token"], k)
#   }
# }

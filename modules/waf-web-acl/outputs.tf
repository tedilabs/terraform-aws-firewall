output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_wafv2_web_acl.this.region
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the WAF Web ACL."
  value       = aws_wafv2_web_acl.this.arn
}

output "id" {
  description = "The ID of the "
  value       = aws_wafv2_web_acl.this.id
}

output "name" {
  description = "The name of the WAF Web ACL."
  value       = aws_wafv2_web_acl.this.name
}

output "description" {
  description = "The description of the WAF Web ACL."
  value       = aws_wafv2_web_acl.this.description
}

output "is_global" {
  description = "Whether this is for a global application(AWS CloudFront distribution) or for a regional application."
  value       = aws_wafv2_web_acl.this.scope == "CLOUDFRONT"
}

output "application_integration_url" {
  description = "The URL to use in SDK integrations with managed rule groups."
  value       = aws_wafv2_web_acl.this.application_integration_url
}

output "capacity" {
  description = "The web ACL capacity units (WCUs) currently being used by this web ACL."
  value       = aws_wafv2_web_acl.this.capacity
}

output "default_action" {
  description = "The action to perform if none of the Rules contained in the WebACL match."
  value       = length(aws_wafv2_web_acl.this.default_action[0].allow[*]) > 0 ? "ALLOW" : "BLOCK"
}

output "token_config" {
  description = "The configuration for tokens for the WAF Web ACL."
  value = {
    token_domains = aws_wafv2_web_acl.this.token_domains
    captcha = {
      default_immunity_time = coalesce(one(aws_wafv2_web_acl.this.captcha_config[*].immunity_time_property[0].immunity_time), 300)
    }
    challenge = {
      default_immunity_time = coalesce(one(aws_wafv2_web_acl.this.challenge_config[*].immunity_time_property[0].immunity_time), 300)
    }
  }
}

output "observability" {
  description = "The observability configuration for the WAF Web ACL."
  value = {
    cloudwatch_metrics = {
      enabled     = aws_wafv2_web_acl.this.visibility_config[0].cloudwatch_metrics_enabled
      metric_name = aws_wafv2_web_acl.this.visibility_config[0].metric_name
    }
    request_sampling = {
      enabled = aws_wafv2_web_acl.this.visibility_config[0].sampled_requests_enabled
    }
  }
}

output "resource_associations" {
  description = "The resource associations of the WAF Web ACL."
  value = [
    for assoc in aws_wafv2_web_acl_association.this :
    {
      name         = assoc.key
      resource_arn = assoc.value.resource_arn
    }
  ]
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
#     for k, v in aws_wafv2_web_acl.this :
#     k => v
#     if !contains(["arn", "id", "name", "name_prefix", "description", "capacity", "visibility_config", "tags", "tags_all", "application_integration_url", "lock_token", "region", "scope", "captcha_config", "challenge_config", "token_domains"], k)
#   }
# }

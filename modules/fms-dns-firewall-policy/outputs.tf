output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_fms_policy.this.region
}

output "arn" {
  description = "The ARN of the AWS Firewall Manager Policy."
  value       = aws_fms_policy.this.arn
}

output "id" {
  description = "The ID of the AWS Firewall Manager Policy."
  value       = aws_fms_policy.this.id
}

output "name" {
  description = "The name of the AWS Firewall Manager Policy."
  value       = aws_fms_policy.this.name
}

output "description" {
  description = "The description of the AWS Firewall Manager Policy."
  value       = aws_fms_policy.this.description
}

output "update_token" {
  description = "The unique identifier for each update to the AWS Firewall Manager Policy."
  value       = aws_fms_policy.this.policy_update_token
}

output "policy" {
  description = "The configuration of this policy."
  value = {
    pre_rule_groups  = var.pre_rule_groups
    post_rule_groups = var.post_rule_groups
  }
}

output "scope" {
  description = "The configuration of this policy scope."
  value = {
    resource_types = var.resource_types
    resource_sets  = aws_fms_policy.this.resource_set_ids
    resource_tags_filter = {
      type     = aws_fms_policy.this.exclude_resource_tags ? "BLACKLIST" : "WHITELIST"
      operator = aws_fms_policy.this.resource_tag_logical_operator
      tags     = aws_fms_policy.this.resource_tags
    }
    organization_filter = var.organization_filter
  }
}

output "attributes" {
  description = "A set of attributes that applied to the AWS Firewall Manager Policy."
  value = {
    auto_remediation_enabled          = aws_fms_policy.this.remediation_enabled
    resource_cleanup_on_leave_enabled = aws_fms_policy.this.delete_unused_fm_managed_resources
    cascade_deletion_enabled          = aws_fms_policy.this.delete_all_policy_resources
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

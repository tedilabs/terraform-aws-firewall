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

locals {
  organization_filter_enabled = length(setunion(
    var.organization_filter.accounts,
    var.organization_filter.organization_units
  )) > 0
}


###################################################
# Security Policy for FMS (Firewall Manager)
###################################################

# INFO: Not supported attributes
# - `resource_type_list`: The resource type of DNS Firewall policy is always `AWS::EC2::VPC`.
# - `resource_set_ids`: Resource sets are only supported by Network Firewall policies.
# - `security_service_policy_data.policy_option`: Only used by Network Firewall, third-party firewall and Network ACL policies.
resource "aws_fms_policy" "this" {
  region = var.region

  name        = var.name
  description = var.description

  ## Policy
  security_service_policy_data {
    type = "DNS_FIREWALL"

    managed_service_data = jsonencode({
      type = "DNS_FIREWALL"

      preProcessRuleGroups = [
        for item in var.pre_rule_groups : {
          priority    = item.priority
          ruleGroupId = item.rule_group
        }
      ]
      postProcessRuleGroups = [
        for item in var.post_rule_groups : {
          priority    = item.priority
          ruleGroupId = item.rule_group
        }
      ]
    })
  }


  ## Scope
  resource_type = "AWS::EC2::VPC"
  # resource_type_list = var.resource_types

  # INFO: `resource_tag_logical_operator` decides how multiple resource tags are combined to filter resources.
  # - `AND`: A resource should have all the tags to be included or excluded.
  # - `OR`: A resource should have at least one of the tags to be included or excluded.
  resource_tags                 = var.resource_tags_filter.tags
  exclude_resource_tags         = var.resource_tags_filter.type == "BLACKLIST"
  resource_tag_logical_operator = var.resource_tags_filter.operator

  dynamic "include_map" {
    for_each = (var.organization_filter.type == "WHITELIST" && local.organization_filter_enabled) ? ["go"] : []

    content {
      account = var.organization_filter.accounts
      orgunit = var.organization_filter.organization_units
    }
  }
  dynamic "exclude_map" {
    for_each = (var.organization_filter.type == "BLACKLIST" && local.organization_filter_enabled) ? ["go"] : []

    content {
      account = var.organization_filter.accounts
      orgunit = var.organization_filter.organization_units
    }
  }


  ## Attributes
  remediation_enabled                = var.auto_remediation_enabled
  delete_unused_fm_managed_resources = var.resource_cleanup_on_leave_enabled
  delete_all_policy_resources        = var.cascade_deletion_enabled

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}

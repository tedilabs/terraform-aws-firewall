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
  managed_domain_lists = yamldecode(file("${path.module}/managed-domain-lists.yaml"))
  managed_domain_list_id = try(
    local.managed_domain_lists[one(data.aws_region.this[*].region)][var.name],
    null,
  )
}


###################################################
# Custom Domain List for DNS Firewall
###################################################

resource "aws_route53_resolver_firewall_domain_list" "this" {
  count = var.type == "CUSTOM" ? 1 : 0

  region = var.region

  name    = var.name
  domains = var.domains

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Managed Domain List for DNS Firewall
###################################################

data "aws_region" "this" {
  count = var.type == "MANAGED" ? 1 : 0

  region = var.region
}

data "aws_route53_resolver_firewall_domain_list" "this" {
  count = var.type == "MANAGED" ? 1 : 0

  region = var.region

  firewall_domain_list_id = local.managed_domain_list_id

  lifecycle {
    precondition {
      condition     = local.managed_domain_list_id != null
      error_message = "The `name` should be the name of an AWS managed domain list which is available in the region. Run `get-managed-domain-lists.sh` to refresh `managed-domain-lists.yaml` if the domain list is missing from it."
    }
  }
}


locals {
  domain_list = (var.type == "CUSTOM"
    ? {
      region       = one(aws_route53_resolver_firewall_domain_list.this[*].region)
      arn          = one(aws_route53_resolver_firewall_domain_list.this[*].arn)
      id           = one(aws_route53_resolver_firewall_domain_list.this[*].id)
      name         = one(aws_route53_resolver_firewall_domain_list.this[*].name)
      domains      = one(aws_route53_resolver_firewall_domain_list.this[*].domains)
      domain_count = length(one(aws_route53_resolver_firewall_domain_list.this[*].domains))
    }
    : {
      region       = one(data.aws_route53_resolver_firewall_domain_list.this[*].region)
      arn          = one(data.aws_route53_resolver_firewall_domain_list.this[*].arn)
      id           = one(data.aws_route53_resolver_firewall_domain_list.this[*].firewall_domain_list_id)
      name         = one(data.aws_route53_resolver_firewall_domain_list.this[*].name)
      domains      = toset([])
      domain_count = one(data.aws_route53_resolver_firewall_domain_list.this[*].domain_count)
    }
  )
}

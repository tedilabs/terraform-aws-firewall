provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}


###################################################
# DNS Firewall Domain Lists
###################################################

# The Aggregate Threat List already includes every domain of the other AWS
# managed domain lists - `AWSManagedDomainsMalwareDomainList`,
# `AWSManagedDomainsBotnetCommandandControl` and
# `AWSManagedDomainsAmazonGuardDutyThreatList` - so pairing it with any of them
# only adds redundant rules.
module "domain_list_aggregate_threat" {
  source = "../../modules/dns-firewall-domain-list"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-domain-list"
  # version = "~> 0.4.0"

  type = "MANAGED"
  name = "AWSManagedDomainsAggregateThreatList"
}

# A domain which the managed list flags but the workload legitimately needs is
# allowed back by a rule with a higher precedence, instead of dropping the
# managed list entirely.
module "domain_list_allowlist" {
  source = "../../modules/dns-firewall-domain-list"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-domain-list"
  # version = "~> 0.4.0"

  name = "example-allowlist"
  domains = [
    "example1.mycompany.com.",
    "example2.mycompany.com.",
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}


###################################################
# DNS Firewall Rule Group
###################################################

module "rule_group" {
  source = "../../modules/dns-firewall-rule-group"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-rule-group"
  # version = "~> 0.4.0"

  name = "example-managed-threat-protection"
  rules = [
    # DNS Firewall evaluates the rules from the lowest priority, so the
    # allowlist has to come first to override the managed list below it.
    {
      priority    = 100
      name        = "allow-known-good"
      domain_list = module.domain_list_allowlist.id
      action      = "ALLOW"
    },
    # AWS recommends running a managed list with the `ALERT` action first, and
    # switching to `BLOCK` once the CloudWatch metrics and the query logs show
    # no false positive.
    {
      priority    = 200
      name        = "block-aggregate-threat"
      domain_list = module.domain_list_aggregate_threat.id
      action      = "BLOCK"
      action_parameters = {
        response = "NODATA"
      }
    },
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}


###################################################
# DNS Firewall
###################################################

module "firewall" {
  source = "../../modules/dns-firewall"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall"
  # version = "~> 0.4.0"

  vpc_id = data.aws_vpc.default.id

  # Keep the failure mode closed, so a query which DNS Firewall cannot evaluate
  # is blocked rather than allowed.
  fail_open_enabled = false

  rule_groups = [
    {
      priority = 200
      name     = "example-managed-threat-protection"
      id       = module.rule_group.id

      mutation_protection_enabled = false
    },
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}

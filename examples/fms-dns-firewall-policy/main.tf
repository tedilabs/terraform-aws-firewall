provider "aws" {
  region = "us-east-1"
}


###################################################
# DNS Firewall Domain List
###################################################

module "domain_list_blacklist" {
  source = "../../modules/dns-firewall-domain-list"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-domain-list"
  # version = "~> 0.1.0"

  name = "example-blacklist"
  domains = [
    "example1.blacklist.com.",
    "example2.blacklist.com.",
    "example3.blacklist.com.",
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}

module "domain_list_whitelist" {
  source = "../../modules/dns-firewall-domain-list"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-domain-list"
  # version = "~> 0.1.0"

  name = "example-whitelist"
  domains = [
    "example1.whitelist.com.",
    "example2.whitelist.com.",
    "example3.whitelist.com.",
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}



###################################################
# DNS Firewall Rule Group
###################################################

module "rule_group_1" {
  source = "../../modules/dns-firewall-rule-group"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-rule-group"
  # version = "~> 0.1.0"

  name = "block-blacklist"
  rules = [
    {
      priority    = 10
      name        = "block-example"
      domain_list = module.domain_list_blacklist.id
      action      = "BLOCK"
      action_parameters = {
        response = "OVERRIDE"
        override = {
          type  = "CNAME"
          value = "404.mycompany.com."
          ttl   = 60
        }
      }
    },
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}

module "rule_group_2" {
  source = "../../modules/dns-firewall-rule-group"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-rule-group"
  # version = "~> 0.1.0"

  name = "allow-whitelist"
  rules = [
    {
      priority    = 10
      name        = "allow-example"
      domain_list = module.domain_list_whitelist.id
      action      = "ALLOW"
    },
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}


###################################################
# DNS Firewall
###################################################

module "policy" {
  source = "../../modules/fms-dns-firewall-policy"
  # source  = "tedilabs/firewall/aws//modules/fms-dns-firewall-policy"
  # version = "~> 0.1.0"

  name = "dns-firewall-example"

  ## Policy
  pre_rule_groups = [
    {
      priority   = 10
      rule_group = module.rule_group_2.id,
    }
  ]
  post_rule_groups = [
    {
      priority   = 10000
      rule_group = module.rule_group_1.id,
    }
  ]

  ## Scope
  resource_types = ["AWS::EC2::VPC"]
  resource_tags_filter = {
    type = "BLACKLIST"
    tags = {
      "Team" = "security"
    }
  }
  organization_filter = {
    type     = "WHITELIST"
    accounts = ["911145092815"]
  }

  ## Attributes
  auto_remediation_enabled          = true
  resource_cleanup_on_leave_enabled = true
  cascade_deletion_enabled          = true

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}

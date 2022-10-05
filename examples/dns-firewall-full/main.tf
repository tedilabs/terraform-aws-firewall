provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}


###################################################
# DNS Firewall Domain List
###################################################

module "domain_list" {
  source = "../../modules/dns-firewall-domain-list"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall-domain-list"
  # version = "~> 0.1.0"

  name = "example"
  domains = [
    "example1.mycompany.com.",
    "example2.mycompany.com.",
    "example3.mycompany.com.",
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
  # version = "~> 0.1.0"

  name = "block-blacklist"
  rules = [
    {
      priority    = 10
      name        = "block-example"
      domain_list = module.domain_list.id
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


###################################################
# DNS Firewall
###################################################

module "firewall" {
  source = "../../modules/dns-firewall"
  # source  = "tedilabs/firewall/aws//modules/dns-firewall"
  # version = "~> 0.1.0"

  vpc_id            = data.aws_vpc.default.id
  fail_open_enabled = true

  rule_groups = []

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}

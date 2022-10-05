provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}


###################################################
# DNS Firewall
###################################################

module "dns_firewall" {
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

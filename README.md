# terraform-aws-firewall

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-firewall?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-firewall?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates firewall related resources on AWS.

- [dns-firewall](./modules/dns-firewall)
- [dns-firewall-domain-list](./modules/dns-firewall-domain-list)
- [dns-firewall-rule-group](./modules/dns-firewall-rule-group)
- [fms-dns-firewall-policy](./modules/fms-dns-firewall-policy)
- [network-firewall](./modules/network-firewall)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-firewall) were written to manage the following AWS Services with Terraform.

- **AWS FMS (Firewall Manager)**
  - Security Policy
- **AWS Route53 DNS Firewall**
  - Firewall
  - Firewall Rule Group
  - Firewall Domain List
- **AWS VPC Network Firewall**
  - Firewall


## Usage

### Route53 DNS Firewall

```tf
data "aws_vpc" "default" {
  default = true
}


###################################################
# DNS Firewall Domain List
###################################################

module "domain_list" {
  source  = "tedilabs/firewall/aws//modules/dns-firewall-domain-list"
  version = "~> 0.1.0"

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
  source  = "tedilabs/firewall/aws//modules/dns-firewall-rule-group"
  version = "~> 0.1.0"

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
  source  = "tedilabs/firewall/aws//modules/dns-firewall"
  version = "~> 0.1.0"

  vpc_id            = data.aws_vpc.default.id
  fail_open_enabled = true

  rule_groups = [
    {
      priority = 200
      id       = module.rule_group.id
    },
  ]

  tags = {
    "project" = "terraform-aws-firewall-examples"
  }
}

```


## Examples

### Route53 DNS Firewall

- [Route53 DNS Firewall Full Version](./examples/dns-firewall-full)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-firewall). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022, [Byungjin Park](https://www.posquit0.com).

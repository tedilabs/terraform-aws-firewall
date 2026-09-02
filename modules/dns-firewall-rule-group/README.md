# dns-firewall-rule-group

This module creates following resources.

- `aws_route53_resolver_firewall_rule_group`
- `aws_route53_resolver_firewall_rule` (optional)
- `aws_route53profiles_resource_association` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.29 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.62.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |
| <a name="module_share"></a> [share](#module\_share) | tedilabs/organization/aws//modules/ram-share | ~> 0.8.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_route53_resolver_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group) | resource |
| [aws_route53profiles_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53profiles_resource_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | (Required) Friendly name of the firewall rule group. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the firewall rule group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_profile_associations"></a> [profile\_associations](#input\_profile\_associations) | (Optional) A list of configurations to associate Route53 Profiles with the firewall rule group. Sharing a rule group through a Route53 Profile applies it to every VPC which the Profile is associated with. Each block of `profile_associations` as defined below.<br/>    (Required) `name` - The name of the resource association with the Route53 profile.<br/>    (Required) `profile` - The ID of the Route53 profile to associate with.<br/>    (Required) `priority` - The setting that determines the processing order of the rule group among the rule groups which the Route53 profile applies to the VPC. DNS Firewall filters VPC traffic starting from the rule group with the lowest numeric priority setting. Valid values are between 100 and 9900. | <pre>list(object({<br/>    name     = string<br/>    profile  = string<br/>    priority = number<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | (Optional) The rules that you define for the firewall rule group determine the filtering behavior. Each rule consists of a priority, an action and the criteria to match - either a domain list (standard rule) or a DNS threat protection (DNS Firewall Advanced rule). Each item of `rules` block as defined below.<br/>    (Required) `priority` - Determine the processing order of the rule in the rule group. DNS Firewall processes the rules in a rule group by order of priority, starting from the lowest priority.<br/>    (Required) `name` - A name that lets you identify the rule.<br/>    (Optional) `description` - The description of the rule.<br/>    (Optional) `domain_list` - The ID of the domain list that you want to use in the rule. Required for standard rules. Conflicts with `threat_protection`.<br/>    (Optional) `threat_protection` - The configuration for a DNS Firewall Advanced rule, which inspects DNS query patterns to detect threats instead of matching a domain list. Conflicts with `domain_list`. `threat_protection` block as defined below.<br/>      (Required) `type` - The type of the DNS Firewall Advanced rule. Valid values are `DGA`, `DICTIONARY_DGA`, `DNS_TUNNELING`.<br/>      (Required) `confidence_threshold` - The confidence threshold of the DNS Firewall Advanced rule. A lower threshold detects more threats with more false positives. Valid values are `LOW`, `MEDIUM`, `HIGH`.<br/>    (Optional) `query_type` - The DNS query type that you want the rule to evaluate. For example, `A`, `AAAA`, `CNAME` or the numeric representation of the DNS record type. If not provided, the rule evaluates all the query types.<br/>    (Optional) `dns_redirection_chain_inspection_mode` - How the rule evaluates the DNS redirection in the DNS redirection chain, such as CNAME or DNAME. Valid values are `INSPECT` and `TRUST`. Defaults to `INSPECT`. Only applied to standard rules.<br/>      `INSPECT` - Inspects all the domains in the redirection chain. The individual domains in the redirection chain must be added to the domain list.<br/>      `TRUST` - Inspects only the first domain in the redirection chain. You don't need to add the subsequent domains in the redirection chain to the domain list.<br/>    (Required) `action` - The action that DNS Firewall should take on a DNS query when it matches one of the domains in the rule's domain list, or a threat in a DNS Firewall Advanced rule. Valid values are `ALLOW`, `BLOCK`, `ALERT`. `ALLOW` is not valid for DNS Firewall Advanced rules.<br/>    (Optional) `action_parameters` - The configuration block for the parameters of the rule action. Only required with `BLOCK` action. `action_parameters` block as defined below.<br/>      (Required) `response` - The way that you want DNS Firewall to block the request. Valid values are `NODATA`, `NXDOMAIN`, `OVERRIDE`. `NODATA` indicates that this query was successful, but there is no response available for the query. `NXDOMAIN` indicates that the domain name that's in the query doesn't exist. `OVERRIDE` provides a custom override response to the query. Defaults to `NODATA`.<br/>      (Optional) `override` - The configuration for a custom override response to the query. Only required with `OVERRIDE` block response.<br/>        (Required) `type` - The DNS record's type. This determines the format of the record value that you provided in BlockOverrideDomain. Value values are `CNAME`.<br/>        (Required) `value` - The custom DNS record to send back in response to the query.<br/>        (Required) `ttl` - The recommended amount of time, in seconds, for the DNS resolver or web browser to cache the provided override record. Minimum value of `0`. Maximum value of `604800`. | <pre>list(object({<br/>    priority    = number<br/>    name        = string<br/>    description = optional(string, "Managed by Terraform.")<br/><br/>    domain_list = optional(string)<br/>    threat_protection = optional(object({<br/>      type                 = string<br/>      confidence_threshold = string<br/>    }))<br/><br/>    query_type                            = optional(string)<br/>    dns_redirection_chain_inspection_mode = optional(string, "INSPECT")<br/><br/>    action = string<br/>    action_parameters = optional(object({<br/>      response = optional(string, "NODATA")<br/>      override = optional(object({<br/>        type  = string<br/>        value = string<br/>        ttl   = optional(number, 0)<br/>      }))<br/>    }), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | (Optional) A list of resource shares via RAM (Resource Access Manager). | <pre>list(object({<br/>    name = optional(string)<br/><br/>    permissions = optional(set(string), ["AWSRAMDefaultPermissionResolverFirewallRuleGroup"])<br/><br/>    external_principals_allowed = optional(bool, false)<br/>    principals                  = optional(set(string), [])<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the firewall rule group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the firewall rule group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the firewall rule group. |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The AWS Account ID for the account that created the rule group. |
| <a name="output_profile_associations"></a> [profile\_associations](#output\_profile\_associations) | A list of Route53 Profile associations with the firewall rule group. Each value of `profile_associations` as defined below.<br/>    `id` - The ID of the Route53 Profile resource association.<br/>    `name` - The name of the Route53 Profile resource association.<br/>    `owner_id` - The AWS Account ID of the owner of the Route53 Profile resource association.<br/>    `status` - The status of the Route53 Profile resource association.<br/>    `profile` - The information of the associated Route53 Profile. `profile` as defined below.<br/>      `id` - The ID of the Route53 Profile.<br/>      `region` - The AWS region which the Route53 Profile resource association resides in.<br/>    `resource` - The information of the associated resource. `resource` as defined below.<br/>      `type` - The type of the associated resource.<br/>      `arn` - The ARN of the associated resource.<br/>      `properties` - The properties of the associated resource. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_rules"></a> [rules](#output\_rules) | The rules of the firewall rule group. Each value of `rules` is keyed by the priority of the rule as defined below.<br/>    `id` - The ID of the rule.<br/>    `name` - The name of the rule.<br/>    `domain_list` - The ID of the domain list which is used in the rule. Only set for standard rules.<br/>    `threat_protection` - The configuration of the DNS Firewall Advanced rule. Only set for DNS Firewall Advanced rules.<br/>    `query_type` - The DNS query type which the rule evaluates.<br/>    `dns_redirection_chain_inspection_mode` - How the rule evaluates the DNS redirection in the DNS redirection chain.<br/>    `action` - The action which DNS Firewall takes on a matched DNS query.<br/>    `action_parameters` - The parameters of the rule action. |
| <a name="output_sharing"></a> [sharing](#output\_sharing) | The configuration for sharing of the Route53 Resolver DNS Firewall Rule Group.<br/>    `status` - An indication of whether the rule group is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.<br/>    `shares` - The list of resource shares via RAM (Resource Access Manager). |
<!-- END_TF_DOCS -->

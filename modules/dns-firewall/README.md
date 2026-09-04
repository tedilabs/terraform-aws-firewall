# dns-firewall

This module creates following resources.

- `aws_route53_resolver_firewall_config` (optional)
- `aws_route53_resolver_firewall_rule_group_association` (optional)
- `aws_route53profiles_resource_association` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.12 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_route53_resolver_firewall_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_config) | resource |
| [aws_route53_resolver_firewall_rule_group_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group_association) | resource |
| [aws_route53profiles_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53profiles_resource_association) | resource |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_resolver_firewall_rule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_resolver_firewall_rule_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_target"></a> [target](#input\_target) | (Required) The configuration of the target to associate the DNS Firewall rule groups with. `target` as defined below.<br/>    (Required) `type` - The type of the target. Valid values are `VPC` and `ROUTE53_PROFILE`. Associating rule groups with a Route53 Profile applies them to every VPC which the Profile is associated with.<br/>    (Required) `id` - The ID of the target. The ID of the VPC if `type` is `VPC`, or the ID of the Route53 Profile if `type` is `ROUTE53_PROFILE`. | <pre>object({<br/>    type = string<br/>    id   = string<br/>  })</pre> | n/a | yes |
| <a name="input_fail_open_enabled"></a> [fail\_open\_enabled](#input\_fail\_open\_enabled) | (Optional) Determines how Route 53 Resolver handles queries during failures, for example when all traffic that is sent to DNS Firewall fails to receive a reply. By default, fail open is disabled, which means the failure mode is closed. This approach favors security over availability. DNS Firewall blocks queries that it is unable to evaluate properly. If you enable this option, the failure mode is open. This approach favors availability over security. DNS Firewall allows queries to proceed if it is unable to properly evaluate them. Only applied when `target.type` is `VPC`, ignored otherwise. | `bool` | `false` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`. Only supported when `target.type` is `VPC`, since associations with a Route53 Profile do not support tags.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_rule_groups"></a> [rule\_groups](#input\_rule\_groups) | (Optional) A list of rule groups associated with the target. Each value of `rule_group` block as defined below.<br/>    (Required) `id` - The ID of the firewall rule group.<br/>    (Required) `priority` - The setting that determines the processing order of the rule group among the rule groups that you associate with the target. DNS Firewall filters VPC traffic starting from the rule group with the lowest numeric priority setting.<br/>    (Required) `name` - A name that lets you identify the association, to manage and use it.<br/>    (Optional) `mutation_protection_enabled` - If enabled, this setting disallows modification or removal of the association, to help prevent against accidentally altering DNS firewall protections. Only applied when `target.type` is `VPC`, ignored otherwise. | <pre>list(object({<br/>    id       = string<br/>    priority = number<br/>    name     = string<br/><br/>    mutation_protection_enabled = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_fail_open_enabled"></a> [fail\_open\_enabled](#output\_fail\_open\_enabled) | Whether the Route53 Resolver handles queries during failures. Only available when `target.type` is `VPC`. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_rule_groups"></a> [rule\_groups](#output\_rule\_groups) | The configuration of rule groups associated with the target. Each value of `rule_groups` is keyed by the priority of the rule group association as defined below.<br/>    `id` - The ID of the firewall rule group.<br/>    `name` - The name of the association.<br/>    `priority` - The processing order of the rule group among the rule groups associated with the target.<br/>    `mutation_protection_enabled` - Whether the modification or removal of the association is disallowed.<br/>    `association` - The information of the rule group association resource. `association` as defined below.<br/>      `arn` - The ARN of the firewall rule group association. Only available when `target.type` is `VPC`.<br/>      `id` - The ID of the firewall rule group association. |
| <a name="output_target"></a> [target](#output\_target) | The target which the DNS Firewall rule groups are associated with.<br/>    `type` - The type of the target. Either `VPC` or `ROUTE53_PROFILE`.<br/>    `id` - The ID of the target. |
<!-- END_TF_DOCS -->

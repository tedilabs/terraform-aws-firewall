# dns-firewall-domain-list

This module creates following resources if `var.type` is `CUSTOM`.

- `aws_route53_resolver_firewall_domain_list`

Or reads following data sources if `var.type` is `MANAGED`.

- `aws_region`
- `aws_route53_resolver_firewall_domain_list`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.12 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.62.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_route53_resolver_firewall_domain_list.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list) | resource |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_resolver_firewall_domain_list.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_resolver_firewall_domain_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | (Required) A name to identify the domain list. If `type` is `MANAGED`, this should be the name of an AWS managed domain list like `AWSManagedDomainsMalwareDomainList`, and the module resolves its region-specific ID from `managed-domain-lists.yaml`. | `string` | n/a | yes |
| <a name="input_domains"></a> [domains](#input\_domains) | (Optional) A set of domains for the firewall domain list. Only applicable if `type` is `CUSTOM`. | `set(string)` | `[]` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) The type of the domain list. Valid values are `CUSTOM` and `MANAGED`. Defaults to `CUSTOM`.<br/>    `CUSTOM` - Create and manage a domain list with the domains provided by `domains`.<br/>    `MANAGED` - Look up an AWS managed domain list by `name`. No resource is created, and `domains` is not applicable because AWS owns the domains of a managed domain list. | `string` | `"CUSTOM"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the domain list. |
| <a name="output_domain_count"></a> [domain\_count](#output\_domain\_count) | The number of domains in the firewall domain list. Unlike `domains`, this is also populated if `type` is `MANAGED`. |
| <a name="output_domains"></a> [domains](#output\_domains) | The set of domains from the firewall domain list. Always empty if `type` is `MANAGED`, because AWS does not disclose the domains of its managed domain lists. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the domain list. |
| <a name="output_name"></a> [name](#output\_name) | The name of the domain list. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->

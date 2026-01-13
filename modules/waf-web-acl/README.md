# waf-web-acl

This module creates following resources.

- `aws_wafv2_web_acl`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | (Required) The action to perform if none of the Rules contained in the WebACL match. `default_action` as defined below. Valid values are `ALLOW`, `BLOCK`. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) A name of the WAF Web ACL. | `string` | n/a | yes |
| <a name="input_custom_request_headers"></a> [custom\_request\_headers](#input\_custom\_request\_headers) | (Optional) A list of custom HTTP headers to insert into the request. Only used if the `default_action` is set to `ALLOW`. Each items of `custom_requeset_headers` block as defined below.<br/>    (Required) `name` - The name of the custom HTTP header. For custom request header insertion, when AWS WAF inserts the header into the request, it prefixes this name `x-amzn-waf-`, to avoid confusion with the headers that are already in the request. For example, for the header name `sample`, AWS WAF inserts the header `x-amzn-waf-sample`.<br/>    (Required) `value` - The value of the custom HTTP header. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_response"></a> [custom\_response](#input\_custom\_response) | (Optional) A custom response to send to the client. Only used if the `default_action` is set to `BLOCK`. `custom_response` as defined below.<br/>    (Required) `status_code` - The HTTP status code to return to the client.<br/>    (Optional) `headers` - A list of custom HTTP headers to include in the response. Each items of `headers` block as defined below.<br/>      (Required) `name` - The name of the custom HTTP header. For custom request header insertion, when AWS WAF inserts the header into the request, it prefixes this name `x-amzn-waf-`, to avoid confusion with the headers that are already in the request. For example, for the header name `sample`, AWS WAF inserts the header `x-amzn-waf-sample`.<br/>      (Required) `value` - The value of the custom HTTP header. | <pre>object({<br/>    status_code = number<br/>    headers = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the WAF Web ACL. Defaults to `Managed by Terraform.`. | `string` | `"Managed by Terraform."` | no |
| <a name="input_is_global"></a> [is\_global](#input\_is\_global) | (Optional) Specify whether this is for a global application(AWS CloudFront distribution) or for a regional application. Defaults to `false`. To work with a global application, you must also specify the Region US East (N. Virginia). | `bool` | `false` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_observability"></a> [observability](#input\_observability) | (Optional) A configurations for WAF observability features. `observability` as defined below.<br/>    (Optional) `cloudwatch_metrics` - A configurations for CloudWatch metrics. `cloudwatch_metrics` as defined below.<br/>      (Optional) `enabled` - Whether to enable CloudWatch metrics for the Web ACL. Defaults to `false`.<br/>      (Optional) `metric_name` - The name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (\_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF, for example `All` and `Default_Action`. If not provided, the Web ACL name will be used.<br/>    (Optional) `request_sampling` - A configurations for request sampling. `request_sampling` as defined below.<br/>      (Optional) `enabled` - Whether AWS WAF should store a sampling of the web requests that match the rules. You can view the sampled requests through the AWS WAF console. Defaults to `false`. | <pre>object({<br/>    cloudwatch_metrics = optional(object({<br/>      enabled     = optional(bool, false)<br/>      metric_name = optional(string, "")<br/>    }), {})<br/>    request_sampling = optional(object({<br/>      enabled = optional(bool, false)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_token_config"></a> [token\_config](#input\_token\_config) | (Optional) A configurations of tokens for the WAF Web ACL. `token_config` as defined below.<br/>    (Optional) `token_domains` - A set of domains that AWS WAF should accept in a web request token. This enables the use of tokens across multiple protected websites. When AWS WAF provides a token, it uses the domain of the AWS resource that the web ACL is protecting. If you don't specify a set of token domains, AWS WAF accepts tokens only for the domain of the protected resource. With `token_domains`, AWS WAF accepts the resource's host domain plus all domains in `token_domains`, including their prefixed subdomains.<br/>    (Optional) `captcha` - A configurations for CAPTCHA token settings. `captcha` as defined below.<br/>      (Optional) `default_immunity_time` - Specify how long CAPTCHA tokens can be used after they are created. This value must be between `60` to `259200` seconds. This value apply for rules which do not have their own settings.<br/>    (Optional) `challenge` - A configurations for Challenge token settings. `challenge` as defined below.<br/>      (Optional) `default_immunity_time` - Specify how long Challenge tokens can be used after they are created. This value must be between `300` to `259200` seconds. This value apply for rules which do not have their own settings. | <pre>object({<br/>    token_domains = optional(set(string), [])<br/>    captcha = optional(object({<br/>      default_immunity_time = optional(number, 300)<br/>    }), {})<br/>    challenge = optional(object({<br/>      default_immunity_time = optional(number, 300)<br/>    }), {})<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_integration_url"></a> [application\_integration\_url](#output\_application\_integration\_url) | The URL to use in SDK integrations with managed rule groups. |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the WAF Web ACL. |
| <a name="output_capacity"></a> [capacity](#output\_capacity) | The web ACL capacity units (WCUs) currently being used by this web ACL. |
| <a name="output_default_action"></a> [default\_action](#output\_default\_action) | The action to perform if none of the Rules contained in the WebACL match. |
| <a name="output_description"></a> [description](#output\_description) | The description of the WAF Web ACL. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the |
| <a name="output_is_global"></a> [is\_global](#output\_is\_global) | Whether this is for a global application(AWS CloudFront distribution) or for a regional application. |
| <a name="output_lock_token"></a> [lock\_token](#output\_lock\_token) | The lock token used for optimistic locking. |
| <a name="output_name"></a> [name](#output\_name) | The name of the WAF Web ACL. |
| <a name="output_observability"></a> [observability](#output\_observability) | The observability configuration for the WAF Web ACL. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_token_config"></a> [token\_config](#output\_token\_config) | The configuration for tokens for the WAF Web ACL. |
<!-- END_TF_DOCS -->

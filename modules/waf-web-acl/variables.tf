variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) A name of the WAF Web ACL."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the WAF Web ACL. Defaults to `Managed by Terraform.`."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "is_global" {
  description = "(Optional) Specify whether this is for a global application(AWS CloudFront distribution) or for a regional application. Defaults to `false`. To work with a global application, you must also specify the Region US East (N. Virginia)."
  type        = bool
  default     = false
  nullable    = false
}

variable "default_action" {
  description = "(Required) The action to perform if none of the Rules contained in the WebACL match. `default_action` as defined below. Valid values are `ALLOW`, `BLOCK`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["ALLOW", "BLOCK"], var.default_action)
    error_message = "Valid values for `default_action` are `ALLOW` or `BLOCK`."
  }
}

variable "custom_request" {
  description = <<EOF
  (Optional) A custom request to insert into the request. Only used if the `default_action` is set to `ALLOW`. `custom_request` as defined below.
    (Optional) `headers` - A list of custom HTTP headers to insert into the request. Only used if the `default_action` is set to `ALLOW`. Each items of `custom_requeset_headers` block as defined below.
      (Required) `name` - The name of the custom HTTP header. For custom request header insertion, when AWS WAF inserts the header into the request, it prefixes this name `x-amzn-waf-`, to avoid confusion with the headers that are already in the request. For example, for the header name `sample`, AWS WAF inserts the header `x-amzn-waf-sample`.
      (Required) `value` - The value of the custom HTTP header.
  EOF
  type = object({
    headers = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  default  = {}
  nullable = false
}

variable "custom_response" {
  description = <<EOF
  (Optional) A custom response to send to the client. Only used if the `default_action` is set to `BLOCK`. `custom_response` as defined below.
    (Required) `status_code` - The HTTP status code to return to the client.
    (Optional) `headers` - A list of custom HTTP headers to include in the response. Each items of `headers` block as defined below.
      (Required) `name` - The name of the custom HTTP header. For custom request header insertion, when AWS WAF inserts the header into the request, it prefixes this name `x-amzn-waf-`, to avoid confusion with the headers that are already in the request. For example, for the header name `sample`, AWS WAF inserts the header `x-amzn-waf-sample`.
      (Required) `value` - The value of the custom HTTP header.
  EOF
  type = object({
    status_code = number
    headers = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  default  = null
  nullable = true
}

variable "token_config" {
  description = <<EOF
  (Optional) A configurations of tokens for the WAF Web ACL. `token_config` as defined below.
    (Optional) `token_domains` - A set of domains that AWS WAF should accept in a web request token. This enables the use of tokens across multiple protected websites. When AWS WAF provides a token, it uses the domain of the AWS resource that the web ACL is protecting. If you don't specify a set of token domains, AWS WAF accepts tokens only for the domain of the protected resource. With `token_domains`, AWS WAF accepts the resource's host domain plus all domains in `token_domains`, including their prefixed subdomains.
    (Optional) `captcha` - A configurations for CAPTCHA token settings. `captcha` as defined below.
      (Optional) `default_immunity_time` - Specify how long CAPTCHA tokens can be used after they are created. This value must be between `60` to `259200` seconds. This value apply for rules which do not have their own settings.
    (Optional) `challenge` - A configurations for Challenge token settings. `challenge` as defined below.
      (Optional) `default_immunity_time` - Specify how long Challenge tokens can be used after they are created. This value must be between `300` to `259200` seconds. This value apply for rules which do not have their own settings.
  EOF
  type = object({
    token_domains = optional(set(string), [])
    captcha = optional(object({
      default_immunity_time = optional(number, 300)
    }))
    challenge = optional(object({
      default_immunity_time = optional(number, 300)
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition = var.token_config.captcha == null || alltrue([
      var.token_config.captcha.default_immunity_time >= 60,
      var.token_config.captcha.default_immunity_time <= 259200,
    ])
    error_message = "Valid value for `token_config.captcha.default_immunity_time` is between 60 and 259200 seconds."
  }
  validation {
    condition = var.token_config.challenge == null || alltrue([
      var.token_config.challenge.default_immunity_time >= 300,
      var.token_config.challenge.default_immunity_time <= 259200,
    ])
    error_message = "Valid value for `token_config.challenge.default_immunity_time` is between 300 and 259200 seconds."
  }
}

variable "observability" {
  description = <<EOF
  (Optional) A configurations for WAF observability features. `observability` as defined below.
    (Optional) `cloudwatch_metrics` - A configurations for CloudWatch metrics. `cloudwatch_metrics` as defined below.
      (Optional) `enabled` - Whether to enable CloudWatch metrics for the Web ACL. Defaults to `false`.
      (Optional) `metric_name` - The name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF, for example `All` and `Default_Action`. If not provided, the Web ACL name will be used.
    (Optional) `request_sampling` - A configurations for request sampling. `request_sampling` as defined below.
      (Optional) `enabled` - Whether AWS WAF should store a sampling of the web requests that match the rules. You can view the sampled requests through the AWS WAF console. Defaults to `false`.
  EOF
  type = object({
    cloudwatch_metrics = optional(object({
      enabled     = optional(bool, false)
      metric_name = optional(string, "")
    }), {})
    request_sampling = optional(object({
      enabled = optional(bool, false)
    }), {})
  })
  default  = {}
  nullable = false
}

variable "resource_config" {
  description = <<EOF
  (Optional) A configurations of resources for the WAF Web ACL. `resource_config` as defined below.
    (Optional) `api_gateawy` - A configurations for API Gateway resources. `api_gateway` as defined below.
      (Optional) `web_request_body_inspection_size_limit` - The maximum size of the request body that AWS WAF inspects for the resource. Valid values are `KB_16`, `KB_32`, `KB_48`, `KB_64`. Defaults to `KB_16`.
    (Optional) `app_runner_service` - A configurations for App Runner Service resources. `app_runner_service` as defined below.
      (Optional) `web_request_body_inspection_size_limit` - The maximum size of the request body that AWS WAF inspects for the resource. Valid values are `KB_16`, `KB_32`, `KB_48`, `KB_64`. Defaults to `KB_16`.
    (Optional) `cloudfront` - A configurations for CloudFront resources. `cloudfront` as defined below.
      (Optional) `web_request_body_inspection_size_limit` - The maximum size of the request body that AWS WAF inspects for the resource. Valid values are `KB_16`, `KB_32`, `KB_48`, `KB_64`. Defaults to `KB_16`.
    (Optional) `cognito_user_pool` - A configurations for Cognito User Pool resources. `cognito_user_pool` as defined below.
      (Optional) `web_request_body_inspection_size_limit` - The maximum size of the request body that AWS WAF inspects for the resource. Valid values are `KB_16`, `KB_32`, `KB_48`, `KB_64`. Defaults to `KB_16`.
    (Optional) `verified_access_instance` - A configurations for Verified Access Instance resources. `verified_access_instance` as defined below.
      (Optional) `web_request_body_inspection_size_limit` - The maximum size of the request body that AWS WAF inspects for the resource. Valid values are `KB_16`, `KB_32`, `KB_48`, `KB_64`. Defaults to `KB_16`.
  EOF
  type = object({
    api_gateway = optional(object({
      web_request_body_inspection_size_limit = optional(string, "KB_16")
    }))
    app_runner_service = optional(object({
      web_request_body_inspection_size_limit = optional(string, "KB_16")
    }))
    cloudfront = optional(object({
      web_request_body_inspection_size_limit = optional(string, "KB_16")
    }))
    cognito_user_pool = optional(object({
      web_request_body_inspection_size_limit = optional(string, "KB_16")
    }))
    verified_access_instance = optional(object({
      web_request_body_inspection_size_limit = optional(string, "KB_16")
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.resource_config.api_gateway == null || contains(["KB_16", "KB_32", "KB_48", "KB_64"], var.resource_config.api_gateway.web_request_body_inspection_size_limit)
    error_message = "Valid values for `resource_config.api_gateway.web_request_body_inspection_size_limit` are `KB_16`, `KB_32`, `KB_48`, `KB_64`."
  }
  validation {
    condition     = var.resource_config.app_runner_service == null || contains(["KB_16", "KB_32", "KB_48", "KB_64"], var.resource_config.app_runner_service.web_request_body_inspection_size_limit)
    error_message = "Valid values for `resource_config.app_runner_service.web_request_body_inspection_size_limit` are `KB_16`, `KB_32`, `KB_48`, `KB_64`."
  }
  validation {
    condition     = var.resource_config.cloudfront == null || contains(["KB_16", "KB_32", "KB_48", "KB_64"], var.resource_config.cloudfront.web_request_body_inspection_size_limit)
    error_message = "Valid values for `resource_config.cloudfront.web_request_body_inspection_size_limit` are `KB_16`, `KB_32`, `KB_48`, `KB_64`."
  }
  validation {
    condition     = var.resource_config.cognito_user_pool == null || contains(["KB_16", "KB_32", "KB_48", "KB_64"], var.resource_config.cognito_user_pool.web_request_body_inspection_size_limit)
    error_message = "Valid values for `resource_config.cognito_user_pool.web_request_body_inspection_size_limit` are `KB_16`, `KB_32`, `KB_48`, `KB_64`."
  }
  validation {
    condition     = var.resource_config.verified_access_instance == null || contains(["KB_16", "KB_32", "KB_48", "KB_64"], var.resource_config.verified_access_instance.web_request_body_inspection_size_limit)
    error_message = "Valid values for `resource_config.verified_access_instance.web_request_body_inspection_size_limit` are `KB_16`, `KB_32`, `KB_48`, `KB_64`."
  }
}

variable "resource_associations" {
  description = <<EOF
  (Optional) A configurations of resources to associate with this WAF Web ACL. Each items of `resource_associations` block as defined below.
    (Required) `name` - A friendly name of the resource. This value is only used internally within Terraform code.
    (Required) `resource` - The ARN of the resource to associate with the WAF Web ACL.
  EOF
  type = list(object({
    name     = string
    resource = string
  }))
  default  = []
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}

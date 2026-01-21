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
  default  = null
  nullable = true
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

variable "rules" {
  description = <<EOF
  (Optional) A list of rules to include in the WAF Web ACL. Each items of `rules` block as defined below.
    (Required) `name` - A friendly name of the rule. Note that the provider assumes that rules with names matching this pattern, `^ShieldMitigationRuleGroup_<account-id>_<web-acl-guid>_.*`, are AWS-added for automatic application layer DDoS mitigation activities. Such rules will be ignored by the provider unless you explicitly include them in your configuration (for example, by using the AWS CLI to discover their properties and creating matching configuration). However, since these rules are owned and managed by AWS, you may get permission errors.
    (Required) `priority` - The priority of the rule in the web ACL. Rules with a lower priority are evaluated before rules with a higher priority. Valid values are between 0 and 10000.
    (Optional) `labels` - A set of labels to associate with requests that match this rule. Rules that are evaluated later in the same protection pack (web ACL) can reference the labels that this rule adds. A label is a string containing the label name and optional prefix and namespaces. For example, `namespace1:name` or `awswaf:managed:aws:managed-rule-set:namespace1:name`. You can specify up to 5 namespaces in a label. Labels are case sensitive
    (Required) `action` - The action that AWS WAF should take on a web request when it matches the rule's statement. Valid values are `ALLOW`, `BLOCK`, `CAPTCHA`, `CHALLENGE`, `COUNT`.
    (Required) `override_action` - The action to take on a web request when it matches the rule's statement. Valid values are `COUNT`, `NONE`.
    (Required) `statement` - A rule statement that defines the inspection criteria. Supports all AWS WAF statement types including nested logical operators (and_statement, or_statement, not_statement) with arbitrary depth. Each rule can have a completely different statement structure. See: https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statements.html
      (Optional) `ip_set_reference` - A rule statement used to detect web requests coming from particular IP addresses or address ranges. `ip_set_reference` as defined below.
        (Required) `arn` - The ARN of the IP Set to reference.
        (Optional) `forwarded_ip_header` - A configuration for inspecting IP addresses in an HTTP header instead of using the IP address that's reported by the web request origin. `forwarded_ip_header` as defined below.
          (Optional) `enabled` - Whether to use the specified HTTP header for the IP address. May be inconsistent or modified. Defaults to `false`.
          (Optional) `name` - The name of the HTTP header to use for the IP address. `X-Forwarded-For` (XFF) is the most commonly used header for the client and proxy IP addresses. Defaults to `X-Forwarded-For`.
          (Optional) `position` - The position in the header to search for the IP address. The header can contain IP addresses of the original client and of any proxies. Valid values are `FIRST`, `LAST`, or `ANY`. Defaults to `FIRST`.
          (Optional) `fallback_behavior` - Handling for requests that don't have a valid IP address in the specified header. Note that, if the specified header isn't present at all in the request, AWS WAF doesn't apply the rule to the request. Valid values are `MATCH` or `NO_MATCH`. Defaults to `NO_MATCH`.
            `MATCH` - Count and rate limit with other requests that are missing their IP address.
            `NO_MATCH` - Don't apply the rule to the request.
    (Optional) `custom_request` - A custom request handling configuration. Only used with `ALLOW`, `CAPTCHA`, `CHALLENGE`, or `COUNT` actions. `custom_request` as defined below.
      (Optional) `headers` - A list of custom HTTP headers to insert into the request. Each items of `headers` block as defined below.
        (Required) `name` - The name of the custom HTTP header. AWS WAF prefixes this with `x-amzn-waf-`.
        (Required) `value` - The value of the custom HTTP header.
    (Optional) `custom_response` - A custom response configuration. Only used with `BLOCK` action. `custom_response` as defined below.
      (Required) `status_code` - The HTTP status code to return to the client.
      (Optional) `headers` - A list of custom HTTP headers to include in the response. Each items of `headers` block as defined below.
        (Required) `name` - The name of the custom HTTP header. AWS WAF prefixes this with `x-amzn-waf-`.
        (Required) `value` - The value of the custom HTTP header.
    (Optional) `token_config` - A configurations of tokens on the rule level. `token_config` as defined below.
      (Optional) `captcha` - A configurations for CAPTCHA token settings. `captcha` as defined below.
        (Optional) `immunity_time` - Specify how long CAPTCHA tokens can be used after they are created. This value must be between `60` to `259200` seconds. The Web ACL configuration applies to the rule that don't specify this.
      (Optional) `challenge` - A configurations for Challenge token settings. `challenge` as defined below.
        (Optional) `immunity_time` - Specify how long Challenge tokens can be used after they are created. This value must be between `300` to `259200` seconds. The Web ACL configuration applies to the rule that don't specify this.
    (Optional) `observability` - A configurations for WAF observability features on the rule level. `observability` as defined below.
      (Optional) `cloudwatch_metrics` - A configurations for CloudWatch metrics of the rule. `cloudwatch_metrics` as defined below.
        (Optional) `enabled` - Whether to enable CloudWatch metrics for the rule. Defaults to the Web ACL level setting.
        (Optional) `metric_name` - The name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF, for example `All` and `Default_Action`. If not provided, the rule name will be used.
      (Optional) `request_sampling` - A configurations for request sampling of the rule. `request_sampling` as defined below.
        (Optional) `enabled` - Whether AWS WAF should store a sampling of the web requests that match the rule. You can view the sampled requests through the AWS WAF console. Defaults to the Web ACL level setting.
  EOF
  # Note: Using `type = any` because WAF v2 statements support arbitrary nesting of logical operators (and_statement, or_statement, not_statement) which cannot be expressed as a static type constraint in Terraform.
  type = any
  # type = list(object({
  #   name     = string
  #   priority = number
  #   labels   = optional(set(string), [])
  #   action   = string
  #   custom_request = optional(object({
  #     headers = optional(list(object({
  #       name  = string
  #       value = string
  #     })), [])
  #   }))
  #   custom_response = optional(object({
  #     status_code = number
  #     headers = optional(list(object({
  #       name  = string
  #       value = string
  #     })), [])
  #   }))
  #   statement = any
  #   token_config = optional(object({
  #     captcha = optional(object({
  #       immunity_time = optional(number, 300)
  #     }))
  #     challenge = optional(object({
  #       immunity_time = optional(number, 300)
  #     }))
  #   }), {})
  #   observability = optional(object({
  #     cloudwatch_metrics = optional(object({
  #       enabled     = optional(bool)
  #       metric_name = optional(string, "")
  #     }), {})
  #     request_sampling = optional(object({
  #       enabled = optional(bool)
  #     }), {})
  #   }), {})
  # }))
  default  = []
  nullable = false

  validation {
    condition     = can(length(var.rules))
    error_message = "The `rules` variable must be a list."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        can(rule.name),
        can(rule.priority),
        can(rule.action),
        can(rule.statement)
      ])
    ])
    error_message = "Each rule must have required fields: `name`, `priority`, `action`, and `statement`."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      can(tostring(rule.name))
    ])
    error_message = "Each rule's `name` must be a string."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        can(tonumber(rule.priority)),
        rule.priority >= 0,
        rule.priority <= 10000,
      ])
    ])
    error_message = "Valid value for `rules[].priority` is between 0 and 10000."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      contains(["ALLOW", "BLOCK", "CAPTCHA", "CHALLENGE", "COUNT"], rule.action)
    ])
    error_message = "Valid values for `rules[].action` are `ALLOW`, `BLOCK`, `CAPTCHA`, `CHALLENGE`, or `COUNT`."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      can(toset(rule.labels))
      if can(rule.labels)
    ])
    error_message = "The `rules[].labels` must be a set of strings."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      !can(rule.custom_request.headers) || alltrue([
        for header in rule.custom_request.headers :
        can(header.name) && can(header.value)
      ])
      if can(rule.custom_request)
    ])
    error_message = "The `rules[].custom_request.headers` must be a list of objects with `name` and `value` fields."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        can(rule.custom_response.status_code),
        can(tonumber(rule.custom_response.status_code)),
      ])
      if can(rule.custom_response.status_code)
    ])
    error_message = "The `rules[].custom_response` must have a numeric `status_code`."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        for header in rule.custom_response.headers :
        can(header.name) && can(header.value)
      ])
      if can(rule.custom_response.headers)
    ])
    error_message = "The `rules[].custom_response` must have `headers` as a list of objects with `name` and `value` fields."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        rule.token_config.captcha.immunity_time >= 60,
        rule.token_config.captcha.immunity_time <= 259200,
      ])
      if can(rule.token_config.captcha.immunity_time)
    ])
    error_message = "Valid value for `rules[].token_config.captcha.immunity_time` is between 60 and 259200 seconds."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        rule.token_config.challenge.immunity_time >= 300,
        rule.token_config.challenge.immunity_time <= 259200,
      ])
      if can(rule.token_config.challenge.immunity_time)
    ])
    error_message = "Valid value for `rules[].token_config.challenge.immunity_time` is between 300 and 259200 seconds."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      can(tobool(rule.observability.cloudwatch_metrics.enabled))
      if can(rule.observability.cloudwatch_metrics.enabled)
    ])
    error_message = "The `rules[].observability.cloudwatch_metrics.enabled` must be a boolean."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        can(tostring(rule.observability.cloudwatch_metrics.metric_name)),
        rule.observability.cloudwatch_metrics.metric_name == null || (
          length(rule.observability.cloudwatch_metrics.metric_name) >= 1
          && length(rule.observability.cloudwatch_metrics.metric_name) <= 128
        )
      ])
      if can(rule.observability.cloudwatch_metrics.metric_name)
    ])
    error_message = "The `rules[].observability.cloudwatch_metrics.metric_name` must be between 1 and 128 characters."
  }
  validation {
    condition = alltrue([
      for rule in var.rules :
      can(tobool(rule.observability.request_sampling.enabled))
      if can(rule.observability.request_sampling.enabled)
    ])
    error_message = "The `rules[].observability.request_sampling.enabled` must be a boolean."
  }
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
    condition     = var.resource_config.cloudfront == null || var.is_global
    error_message = "`resource_config.cloudfront` can be set only when `is_global` is `true`."
  }
  validation {
    condition = !anytrue([
      var.resource_config.api_gateway != null,
      var.resource_config.app_runner_service != null,
      var.resource_config.cognito_user_pool != null,
      var.resource_config.verified_access_instance != null,
    ]) || !var.is_global
    error_message = "`resource_config.api_gateway`, `resource_config.app_runner_service`, `resource_config.cognito_user_pool`, and `resource_config.verified_access_instance` can be set only when `is_global` is `false`."
  }
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

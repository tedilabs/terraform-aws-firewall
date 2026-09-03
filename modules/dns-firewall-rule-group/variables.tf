variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Friendly name of the firewall rule group."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the firewall rule group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "rules" {
  description = <<EOF
  (Optional) The rules that you define for the firewall rule group determine the filtering behavior. Each rule consists of a priority, an action and the criteria to match - either a domain list (standard rule) or a DNS threat protection (DNS Firewall Advanced rule). Each item of `rules` block as defined below.
    (Required) `priority` - Determine the processing order of the rule in the rule group. DNS Firewall processes the rules in a rule group by order of priority, starting from the lowest priority.
    (Required) `name` - A name that lets you identify the rule.
    (Optional) `description` - The description of the rule.
    (Optional) `domain_list` - The ID of the domain list that you want to use in the rule. Required for standard rules. Conflicts with `threat_protection`.
    (Optional) `threat_protection` - The configuration for a DNS Firewall Advanced rule, which inspects DNS query patterns to detect threats instead of matching a domain list. Conflicts with `domain_list`. `threat_protection` block as defined below.
      (Required) `type` - The type of the DNS Firewall Advanced rule. Valid values are `DGA`, `DICTIONARY_DGA`, `DNS_TUNNELING`.
      (Required) `confidence_threshold` - The confidence threshold of the DNS Firewall Advanced rule. A lower threshold detects more threats with more false positives. Valid values are `LOW`, `MEDIUM`, `HIGH`.
    (Optional) `query_type` - The DNS query type that you want the rule to evaluate. For example, `A`, `AAAA`, `CNAME` or the numeric representation of the DNS record type. If not provided, the rule evaluates all the query types.
    (Optional) `dns_redirection_chain_inspection_mode` - How the rule evaluates the DNS redirection in the DNS redirection chain, such as CNAME or DNAME. Valid values are `INSPECT` and `TRUST`. Defaults to `INSPECT`. Only applied to standard rules.
      `INSPECT` - Inspects all the domains in the redirection chain. The individual domains in the redirection chain must be added to the domain list.
      `TRUST` - Inspects only the first domain in the redirection chain. You don't need to add the subsequent domains in the redirection chain to the domain list.
    (Required) `action` - The action that DNS Firewall should take on a DNS query when it matches one of the domains in the rule's domain list, or a threat in a DNS Firewall Advanced rule. Valid values are `ALLOW`, `BLOCK`, `ALERT`. `ALLOW` is not valid for DNS Firewall Advanced rules.
    (Optional) `action_parameters` - The configuration block for the parameters of the rule action. Only required with `BLOCK` action. `action_parameters` block as defined below.
      (Required) `response` - The way that you want DNS Firewall to block the request. Valid values are `NODATA`, `NXDOMAIN`, `OVERRIDE`. `NODATA` indicates that this query was successful, but there is no response available for the query. `NXDOMAIN` indicates that the domain name that's in the query doesn't exist. `OVERRIDE` provides a custom override response to the query. Defaults to `NODATA`.
      (Optional) `override` - The configuration for a custom override response to the query. Only required with `OVERRIDE` block response.
        (Required) `type` - The DNS record's type. This determines the format of the record value that you provided in BlockOverrideDomain. Value values are `CNAME`.
        (Required) `value` - The custom DNS record to send back in response to the query.
        (Required) `ttl` - The recommended amount of time, in seconds, for the DNS resolver or web browser to cache the provided override record. Minimum value of `0`. Maximum value of `604800`.
  EOF
  type = list(object({
    priority    = number
    name        = string
    description = optional(string, "Managed by Terraform.")

    domain_list = optional(string)
    threat_protection = optional(object({
      type                 = string
      confidence_threshold = string
    }))

    query_type                            = optional(string)
    dns_redirection_chain_inspection_mode = optional(string, "INSPECT")

    action = string
    action_parameters = optional(object({
      response = optional(string, "NODATA")
      override = optional(object({
        type  = string
        value = string
        ttl   = optional(number, 0)
      }))
    }), {})
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        rule.priority >= 0,
        rule.priority <= 10000,
      ])
    ])
    error_message = "Valid value for `rule.priority` from `rules` is between 0 and 10000."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      (rule.domain_list != null) != (rule.threat_protection != null)
    ])
    error_message = "Each rule of `rules` should have exactly one of `rule.domain_list` or `rule.threat_protection`."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      contains(["DGA", "DICTIONARY_DGA", "DNS_TUNNELING"], rule.threat_protection.type)
      if rule.threat_protection != null
    ])
    error_message = "Valid values for `rule.threat_protection.type` from `rules` are `DGA`, `DICTIONARY_DGA`, `DNS_TUNNELING`."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      contains(["LOW", "MEDIUM", "HIGH"], rule.threat_protection.confidence_threshold)
      if rule.threat_protection != null
    ])
    error_message = "Valid values for `rule.threat_protection.confidence_threshold` from `rules` are `LOW`, `MEDIUM`, `HIGH`."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      contains(["INSPECT", "TRUST"], rule.dns_redirection_chain_inspection_mode)
    ])
    error_message = "Valid values for `rule.dns_redirection_chain_inspection_mode` from `rules` are `INSPECT`, `TRUST`."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      contains(["ALLOW", "BLOCK", "ALERT"], rule.action)
    ])
    error_message = "Valid values for `rule.action` from `rules` are `ALLOW`, `BLOCK`, `ALERT`."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      rule.action != "ALLOW"
      if rule.threat_protection != null
    ])
    error_message = "Valid values for `rule.action` from `rules` are `BLOCK`, `ALERT` if `rule.threat_protection` is provided."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      contains(["NODATA", "NXDOMAIN", "OVERRIDE"], rule.action_parameters.response)
      if rule.action == "BLOCK"
    ])
    error_message = "Valid values for `rule.action_parameters.response` from `rules` are `NODATA`, `NXDOMAIN`, `OVERRIDE`."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      rule.action_parameters.override != null
      if rule.action_parameters.response == "OVERRIDE"
    ])
    error_message = "`rule.action_parameters.override` from `rules` must be provided when `rule.action_parameters.response` is `OVERRIDE`."
  }
}

variable "profile_associations" {
  description = <<EOF
  (Optional) A list of configurations to associate Route53 Profiles with the firewall rule group. Sharing a rule group through a Route53 Profile applies it to every VPC which the Profile is associated with. Each block of `profile_associations` as defined below.
    (Required) `name` - The name of the resource association with the Route53 profile.
    (Required) `profile` - The ID of the Route53 profile to associate with.
    (Required) `priority` - The setting that determines the processing order of the rule group among the rule groups which the Route53 profile applies to the VPC. DNS Firewall filters VPC traffic starting from the rule group with the lowest numeric priority setting. Valid values are between 100 and 9900.
  EOF
  type = list(object({
    name     = string
    profile  = string
    priority = number
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for association in var.profile_associations :
      alltrue([
        association.priority >= 100,
        association.priority <= 9900,
      ])
    ])
    error_message = "Valid value for `association.priority` from `profile_associations` is between 100 and 9900."
  }
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


###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

variable "shares" {
  description = "(Optional) A list of resource shares via RAM (Resource Access Manager)."
  type = list(object({
    name = optional(string)

    permissions = optional(set(string), ["AWSRAMDefaultPermissionResolverFirewallRuleGroup"])

    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false
}

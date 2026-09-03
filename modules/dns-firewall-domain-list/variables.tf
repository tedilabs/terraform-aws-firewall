variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "type" {
  description = <<EOF
  (Optional) The type of the domain list. Valid values are `CUSTOM` and `MANAGED`. Defaults to `CUSTOM`.
    `CUSTOM` - Create and manage a domain list with the domains provided by `domains`.
    `MANAGED` - Look up an AWS managed domain list by `name`. No resource is created, and `domains` is not applicable because AWS owns the domains of a managed domain list.
  EOF
  type        = string
  default     = "CUSTOM"
  nullable    = false

  validation {
    condition     = contains(["CUSTOM", "MANAGED"], var.type)
    error_message = "Valid values for `type` are `CUSTOM`, `MANAGED`."
  }
}

variable "name" {
  description = "(Required) A name to identify the domain list. If `type` is `MANAGED`, this should be the name of an AWS managed domain list like `AWSManagedDomainsMalwareDomainList`, and the module resolves its region-specific ID from `managed-domain-lists.yaml`."
  type        = string
  nullable    = false
}

variable "domains" {
  description = "(Optional) A set of domains for the firewall domain list. Only applicable if `type` is `CUSTOM`."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for domain in var.domains :
      substr(domain, -1, 1) == "."
    ])
    error_message = "Each domain should have a dot at the end by following the definition of FQDN(Fully Qualified Domain Name)."
  }

  validation {
    condition     = var.type == "CUSTOM" || length(var.domains) == 0
    error_message = "The `domains` should be empty if `type` is `MANAGED`. AWS owns the domains of a managed domain list."
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

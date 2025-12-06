variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) A name of the IP set."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the IP set. Defaults to `Managed by Terraform.`."
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

variable "ip_address_type" {
  description = "(Required) The type of IP addresses used by the IP set. Valid values are `IPV4` or `IPV6`. Defaults to `IPV4`."
  type        = string
  default     = "IPV4"
  nullable    = false

  validation {
    condition     = contains(["IPV4", "IPV6"], var.ip_address_type)
    error_message = "Valid values are `IPV4` or `IPV6`."
  }
}

variable "ip_addresses" {
  description = "(Optional) A set of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. AWS WAF supports all address ranges for IP versions IPv4 and IPv6."
  type        = set(string)
  default     = []
  nullable    = false
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

variable "name" {
  description = "(Required) Friendly name of the firewall."
  type        = string
}

variable "description" {
  description = "(Optional) The description of the firewall."
  type        = string
  default     = "Managed by Terraform."
}

variable "vpc_id" {
  description = "(Required) The ID of the VPC where AWS Network Firewall should create the firewall."
  type        = string
}

variable "network_mapping" {
  description = <<EOF
  (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least two Availability Zone and one subnet for each zone. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.
    (Required) `subnet_id` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.
  EOF
  type        = map(map(string))
  default     = {}
}

variable "subnet_change_protection_enabled" {
  description = "(Optional) Indicates whether deletion of the associated subnets. Defaults to `false`."
  type        = bool
  default     = false
}

variable "firewall_policy_change_protection_enabled" {
  description = "(Optional) Indicates whether to change the associated firewall policy. Defaults to `false`."
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "(Optional) Indicates whether deletion of the firewall via the AWS API will be protected. Defaults to `false`."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
}

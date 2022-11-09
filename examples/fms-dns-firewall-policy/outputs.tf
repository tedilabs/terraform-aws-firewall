output "domain_lists" {
  value = {
    blacklist = module.domain_list_blacklist
    whitelist = module.domain_list_whitelist
  }
}

output "rule_group" {
  value = [
    module.rule_group_1,
    module.rule_group_2,
  ]
}

output "policy" {
  value = module.policy
}

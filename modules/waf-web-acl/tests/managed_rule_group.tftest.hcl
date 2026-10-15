mock_provider "aws" {}

variables {
  name           = "managed-rule-group-test"
  region         = "us-east-1"
  default_action = "ALLOW"

  resource_group = {
    enabled = false
  }
  telemetry = {
    enabled = false
  }
}

run "managed_rule_groups" {
  command = plan

  variables {
    rules = [
      {
        name            = "ip-reputation"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesAmazonIpReputationList"
            version     = "Version_1.0"
          }
        }
      },
      {
        name            = "anti-ddos"
        priority        = 1
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesAntiDDoSRuleSet"
            rule_action_overrides = [
              { name = "ChallengeAllDuringEvent", action = "COUNT" },
              { name = "ChallengeDDoSRequests", action = "COUNT" },
            ]
            config = {
              anti_ddos = {
                sensitivity_to_block = "MEDIUM"
                challenge = {
                  enabled            = true
                  sensitivity        = "LOW"
                  exempt_uri_regexes = ["\\/api\\/", "\\.(css|js)$"]
                }
              }
            }
          }
        }
      },
      {
        name            = "common"
        priority        = 2
        override_action = "COUNT"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesCommonRuleSet"
            rule_action_overrides = [
              { name = "SizeRestrictions_BODY", action = "ALLOW" },
            ]
            scope_down = {
              not = {
                statement = {
                  byte_match = {
                    search_string         = "/images"
                    positional_constraint = "CONTAINS"
                    field_to_match        = { uri_path = {} }
                  }
                }
              }
            }
          }
        }
      },
      {
        name            = "sqli"
        priority        = 3
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesSQLiRuleSet"
            scope_down = {
              not = {
                statement = {
                  byte_match = {
                    search_string         = "multipart/form-data"
                    positional_constraint = "CONTAINS"
                    field_to_match        = { single_header = { name = "content-type" } }
                    text_transformations  = [{ priority = 0, type = "LOWERCASE" }]
                  }
                }
              }
            }
          }
        }
      },
    ]
  }

  assert {
    condition = alltrue([
      for rule in aws_wafv2_web_acl.this.rule :
      length(rule.action) == 0 && length(rule.override_action) == 1
    ])
    error_message = "Managed rule group rules must render `override_action` instead of `action`."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "ip-reputation"]).vendor_name == "AWS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "ip-reputation"]).name == "AWSManagedRulesAmazonIpReputationList",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "ip-reputation"]).version == "Version_1.0",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.override_action[0] if rule.name == "ip-reputation"]).none) == 1,
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.override_action[0] if rule.name == "ip-reputation"]).count) == 0,
    ])
    error_message = "A managed rule group must render its vendor, name, version, and `NONE` override action."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "anti-ddos"]).managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].sensitivity_to_block == "MEDIUM",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "anti-ddos"]).managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].usage_of_action == "ENABLED",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "anti-ddos"]).managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].sensitivity == "LOW",
      jsonencode([
        for regex in one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "anti-ddos"]).managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].exempt_uri_regular_expression :
        regex.regex_string
      ]) == jsonencode(["\\/api\\/", "\\.(css|js)$"]),
    ])
    error_message = "The anti-DDoS config must render its block sensitivity and challenge settings."
  }

  assert {
    condition = alltrue([
      jsonencode([
        for override in one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "anti-ddos"]).rule_action_override :
        override.name
      ]) == jsonencode(["ChallengeAllDuringEvent", "ChallengeDDoSRequests"]),
      alltrue([
        for override in one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "anti-ddos"]).rule_action_override :
        length(override.action_to_use[0].count) == 1 && length(override.action_to_use[0].allow) == 0
      ]),
    ])
    error_message = "Rule action overrides must render in order with their action."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.override_action[0] if rule.name == "common"]).count) == 1,
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "common"]).rule_action_override[0].action_to_use[0].allow) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "common"]).scope_down_statement[0].not_statement[0].statement[0].byte_match_statement[0].search_string == "/images",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "common"]).scope_down_statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].uri_path) == 1,
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "common"]).managed_rule_group_configs) == 0,
    ])
    error_message = "A managed rule group must render the `COUNT` override action, its rule action overrides, and its scope-down statement."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "sqli"]).scope_down_statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_header[0].name == "content-type",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "sqli"]).scope_down_statement[0].not_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "LOWERCASE",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0] if rule.name == "sqli"]).rule_action_override) == 0,
    ])
    error_message = "A scope-down statement must render its byte match options."
  }
}

run "rule_action_override_actions" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesCommonRuleSet"
            rule_action_overrides = [
              { name = "allow", action = "ALLOW", custom_request = { headers = [{ name = "allowed", value = "true" }] } },
              { name = "block", action = "BLOCK", custom_response = { status_code = 429, headers = [{ name = "blocked", value = "true" }] } },
              { name = "captcha", action = "CAPTCHA" },
              { name = "challenge", action = "CHALLENGE" },
              { name = "count", action = "COUNT", custom_request = { headers = [{ name = "counted", value = "true" }] } },
            ]
          }
        }
      },
    ]
  }

  assert {
    condition = alltrue([
      for override in one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].rule_action_override :
      length(override.action_to_use[0][override.name]) == 1 && sum([
        for action in ["allow", "block", "captcha", "challenge", "count"] :
        length(override.action_to_use[0][action])
      ]) == 1
    ])
    error_message = "Each rule action override must render exactly its own action."
  }

  assert {
    condition = alltrue([
      one(one([for override in one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].rule_action_override : override if override.name == "allow"]).action_to_use[0].allow[0].custom_request_handling[0].insert_header).name == "allowed",
      one([for override in one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].rule_action_override : override if override.name == "block"]).action_to_use[0].block[0].custom_response[0].response_code == 429,
      one(one([for override in one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].rule_action_override : override if override.name == "block"]).action_to_use[0].block[0].custom_response[0].response_header).name == "blocked",
      one(one([for override in one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].rule_action_override : override if override.name == "count"]).action_to_use[0].count[0].custom_request_handling[0].insert_header).name == "counted",
    ])
    error_message = "Rule action overrides must render their custom request and response handling."
  }
}

run "anti_ddos_challenge_disabled" {
  command = plan

  variables {
    rules = [
      {
        name            = "anti-ddos"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesAntiDDoSRuleSet"
            config = {
              anti_ddos = {
                challenge = {
                  enabled = false
                }
              }
            }
          }
        }
      },
    ]
  }

  assert {
    condition = alltrue([
      one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].usage_of_action == "DISABLED",
      one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].sensitivity_to_block == null,
      length(one(aws_wafv2_web_acl.this.rule).statement[0].managed_rule_group_statement[0].managed_rule_group_configs[0].aws_managed_rules_anti_ddos_rule_set[0].client_side_action_config[0].challenge[0].exempt_uri_regular_expression) == 0,
    ])
    error_message = "A disabled challenge must render `DISABLED` and leave the optional settings to AWS defaults."
  }
}

run "action_and_override_action" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        action          = "BLOCK"
        override_action = "NONE"
        statement = {
          managed_rule_group = { vendor_name = "AWS", name = "AWSManagedRulesCommonRuleSet" }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "managed_rule_group_with_action" {
  command = plan

  variables {
    rules = [
      {
        name     = "common"
        priority = 0
        action   = "BLOCK"
        statement = {
          managed_rule_group = { vendor_name = "AWS", name = "AWSManagedRulesCommonRuleSet" }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "override_action_without_managed_rule_group" {
  command = plan

  variables {
    rules = [
      {
        name            = "geo"
        priority        = 0
        override_action = "NONE"
        statement = {
          geo_match = { country_codes = ["KR"] }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "invalid_override_action" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        override_action = "BLOCK"
        statement = {
          managed_rule_group = { vendor_name = "AWS", name = "AWSManagedRulesCommonRuleSet" }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "custom_response_with_override_action" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        override_action = "NONE"
        custom_response = { status_code = 403 }
        statement = {
          managed_rule_group = { vendor_name = "AWS", name = "AWSManagedRulesCommonRuleSet" }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "managed_rule_group_without_name" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = { vendor_name = "AWS" }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "invalid_rule_action_override" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name           = "AWS"
            name                  = "AWSManagedRulesCommonRuleSet"
            rule_action_overrides = [{ name = "NoUserAgent_HEADER", action = "NONE" }]
          }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "duplicate_rule_action_overrides" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesCommonRuleSet"
            rule_action_overrides = [
              { name = "NoUserAgent_HEADER", action = "COUNT" },
              { name = "NoUserAgent_HEADER", action = "ALLOW" },
            ]
          }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "anti_ddos_on_other_rule_group" {
  command = plan

  variables {
    rules = [
      {
        name            = "common"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesCommonRuleSet"
            config = {
              anti_ddos = { challenge = { enabled = true } }
            }
          }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "unsupported_config" {
  command = plan

  variables {
    rules = [
      {
        name            = "bot-control"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesBotControlRuleSet"
            config = {
              bot_control = { inspection_level = "COMMON" }
            }
          }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "anti_ddos_without_challenge" {
  command = plan

  variables {
    rules = [
      {
        name            = "anti-ddos"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesAntiDDoSRuleSet"
            config = {
              anti_ddos = { sensitivity_to_block = "LOW" }
            }
          }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "invalid_anti_ddos_sensitivity" {
  command = plan

  variables {
    rules = [
      {
        name            = "anti-ddos"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesAntiDDoSRuleSet"
            config = {
              anti_ddos = {
                sensitivity_to_block = "EXTREME"
                challenge            = { enabled = true }
              }
            }
          }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

run "too_many_exempt_uri_regexes" {
  command = plan

  variables {
    rules = [
      {
        name            = "anti-ddos"
        priority        = 0
        override_action = "NONE"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesAntiDDoSRuleSet"
            config = {
              anti_ddos = {
                challenge = {
                  enabled            = true
                  exempt_uri_regexes = ["a", "b", "c", "d", "e", "f"]
                }
              }
            }
          }
        }
      },
    ]
  }

  expect_failures = [var.rules]
}

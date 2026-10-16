mock_provider "aws" {}

variables {
  name           = "regex-match-test"
  region         = "us-east-1"
  default_action = "ALLOW"

  resource_group = {
    enabled = false
  }
  telemetry = {
    enabled = false
  }
}

run "regex_statements" {
  command = plan

  variables {
    rules = [
      {
        name     = "regex-match"
        priority = 0
        action   = "BLOCK"
        statement = {
          regex_match = {
            regex_string         = "^/items/[^/]+/status$"
            field_to_match       = { uri_path = {} }
            text_transformations = [{ priority = 0, type = "LOWERCASE" }]
          }
        }
      },
      {
        name     = "regex-pattern-set-reference"
        priority = 1
        action   = "BLOCK"
        statement = {
          regex_pattern_set_reference = {
            arn                            = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/test/12345678-1234-1234-1234-123456789012"
            field_to_match                 = { single_query_argument = { name = "q" } }
            pre_parse_text_transformations = [{ priority = 0, type = "URL_DECODE" }]
          }
        }
      },
      {
        name            = "scope-down"
        priority        = 2
        override_action = "COUNT"
        statement = {
          managed_rule_group = {
            vendor_name = "AWS"
            name        = "AWSManagedRulesAnonymousIpList"
            scope_down = {
              and = {
                statements = [
                  {
                    regex_match = {
                      regex_string   = "^/items/[^/]+/status$"
                      field_to_match = { uri_path = {} }
                    }
                  },
                  {
                    not = {
                      statement = {
                        regex_pattern_set_reference = {
                          arn            = "arn:aws:wafv2:us-east-1:123456789012:regional/regexpatternset/test/12345678-1234-1234-1234-123456789012"
                          field_to_match = { single_header = { name = "host" } }
                        }
                      }
                    }
                  },
                ]
              }
            }
          }
        }
      },
    ]
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "regex-match"]).regex_match_statement[0].regex_string == "^/items/[^/]+/status$",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "regex-match"]).regex_match_statement[0].field_to_match[0].uri_path) == 1,
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "regex-match"]).regex_match_statement[0].text_transformation).type == "LOWERCASE",
    ])
    error_message = "A regex match statement must render its expression, request component, and text transformations."
  }

  assert {
    condition = alltrue([
      endswith(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "regex-pattern-set-reference"]).regex_pattern_set_reference_statement[0].arn, "12345678-1234-1234-1234-123456789012"),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "regex-pattern-set-reference"]).regex_pattern_set_reference_statement[0].field_to_match[0].single_query_argument[0].name == "q",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "regex-pattern-set-reference"]).regex_pattern_set_reference_statement[0].text_transformation).type == "NONE",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "regex-pattern-set-reference"]).regex_pattern_set_reference_statement[0].pre_parse_text_transformation).type == "URL_DECODE",
    ])
    error_message = "A regex pattern set reference statement must render its ARN, request component, and the default and pre-parse text transformations."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0] if rule.name == "scope-down"]).and_statement[0].statement[0].regex_match_statement[0].regex_string == "^/items/[^/]+/status$",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0].managed_rule_group_statement[0].scope_down_statement[0] if rule.name == "scope-down"]).and_statement[0].statement[1].not_statement[0].statement[0].regex_pattern_set_reference_statement[0].field_to_match[0].single_header[0].name == "host",
    ])
    error_message = "Regex statements must render in a scope-down statement."
  }
}

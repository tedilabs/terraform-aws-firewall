mock_provider "aws" {}

variables {
  name           = "ip-set-reference-test"
  region         = "us-east-1"
  default_action = "ALLOW"

  resource_group = {
    enabled = false
  }
  telemetry = {
    enabled = false
  }
}

run "forwarded_ip_header_nested" {
  command = plan

  variables {
    rules = [
      {
        name     = "and"
        priority = 0
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                ip_set_reference = {
                  arn                 = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                  forwarded_ip_header = { enabled = true, name = "X-Client-IP", position = "LAST", fallback_behavior = "MATCH" }
                }
              },
              { geo_match = { country_codes = ["KR"] } },
            ]
          }
        }
      },
      {
        name     = "or"
        priority = 1
        action   = "BLOCK"
        statement = {
          or = {
            statements = [
              {
                ip_set_reference = {
                  arn                 = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                  forwarded_ip_header = { enabled = true, name = "X-Client-IP", position = "LAST", fallback_behavior = "MATCH" }
                }
              },
              { geo_match = { country_codes = ["KR"] } },
            ]
          }
        }
      },
      {
        name     = "not"
        priority = 2
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              ip_set_reference = {
                arn                 = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                forwarded_ip_header = { enabled = true, name = "X-Client-IP", position = "LAST", fallback_behavior = "MATCH" }
              }
            }
          }
        }
      },
      {
        name     = "and_not"
        priority = 3
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                not = {
                  statement = {
                    ip_set_reference = {
                      arn                 = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                      forwarded_ip_header = { enabled = true, name = "X-Client-IP", position = "LAST", fallback_behavior = "MATCH" }
                    }
                  }
                }
              },
              { geo_match = { country_codes = ["KR"] } },
            ]
          }
        }
      },
    ]
  }

  assert {
    condition = alltrue([
      for config in [
        one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0],
        one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0],
        one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0],
        one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0],
      ] :
      config.header_name == "X-Client-IP" && config.position == "LAST" && config.fallback_behavior == "MATCH"
    ])
    error_message = "Nested IP set references must honor the forwarded IP header settings."
  }
}

run "forwarded_ip_header_nested_defaults" {
  command = plan

  variables {
    rules = [
      {
        name     = "enabled"
        priority = 0
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              ip_set_reference = {
                arn                 = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                forwarded_ip_header = { enabled = true }
              }
            }
          }
        }
      },
      {
        name     = "disabled"
        priority = 1
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              ip_set_reference = {
                arn                 = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                forwarded_ip_header = { enabled = false, name = "X-Client-IP" }
              }
            }
          }
        }
      },
    ]
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "enabled"]).not_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].header_name == "X-Forwarded-For",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "enabled"]).not_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].position == "FIRST",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "enabled"]).not_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config[0].fallback_behavior == "NO_MATCH",
    ])
    error_message = "Nested IP set references must default the forwarded IP header to `X-Forwarded-For`, `FIRST`, and `NO_MATCH`."
  }

  assert {
    condition     = length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "disabled"]).not_statement[0].statement[0].ip_set_reference_statement[0].ip_set_forwarded_ip_config) == 0
    error_message = "A disabled forwarded IP header must not render in a nested IP set reference."
  }
}

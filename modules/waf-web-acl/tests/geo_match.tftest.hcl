mock_provider "aws" {}

variables {
  name           = "statement-test"
  region         = "us-east-1"
  default_action = "ALLOW"

  resource_group = {
    enabled = false
  }
  telemetry = {
    enabled = false
  }
}

run "logical_nesting" {
  command = plan

  variables {
    rules = [
      {
        name     = "root"
        priority = 0
        action   = "BLOCK"
        statement = {
          geo_match = {
            country_codes       = ["KR", "JP"]
            forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
          }
        }
      },
      {
        name     = "and"
        priority = 1
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                geo_match = {
                  country_codes       = ["KR", "JP"]
                  forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "or"
        priority = 2
        action   = "BLOCK"
        statement = {
          or = {
            statements = [
              {
                geo_match = {
                  country_codes       = ["KR", "JP"]
                  forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "not"
        priority = 3
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              geo_match = {
                country_codes       = ["KR", "JP"]
                forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
              }
            }
          }
        }
      },
      {
        name     = "and_and"
        priority = 4
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                and = {
                  statements = [
                    {
                      geo_match = {
                        country_codes       = ["KR", "JP"]
                        forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                      }
                    },
                    {
                      ip_set_reference = {
                        arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                      }
                    },
                  ]
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "and_or"
        priority = 5
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                or = {
                  statements = [
                    {
                      geo_match = {
                        country_codes       = ["KR", "JP"]
                        forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                      }
                    },
                    {
                      ip_set_reference = {
                        arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                      }
                    },
                  ]
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "and_not"
        priority = 6
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes       = ["KR", "JP"]
                      forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                    }
                  }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "or_and"
        priority = 7
        action   = "BLOCK"
        statement = {
          or = {
            statements = [
              {
                and = {
                  statements = [
                    {
                      geo_match = {
                        country_codes       = ["KR", "JP"]
                        forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                      }
                    },
                    {
                      ip_set_reference = {
                        arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                      }
                    },
                  ]
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "or_or"
        priority = 8
        action   = "BLOCK"
        statement = {
          or = {
            statements = [
              {
                or = {
                  statements = [
                    {
                      geo_match = {
                        country_codes       = ["KR", "JP"]
                        forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                      }
                    },
                    {
                      ip_set_reference = {
                        arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                      }
                    },
                  ]
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "or_not"
        priority = 9
        action   = "BLOCK"
        statement = {
          or = {
            statements = [
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes       = ["KR", "JP"]
                      forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                    }
                  }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "not_and"
        priority = 10
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              and = {
                statements = [
                  {
                    geo_match = {
                      country_codes       = ["KR", "JP"]
                      forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                    }
                  },
                  {
                    ip_set_reference = {
                      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                    }
                  },
                ]
              }
            }
          }
        }
      },
      {
        name     = "not_or"
        priority = 11
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              or = {
                statements = [
                  {
                    geo_match = {
                      country_codes       = ["KR", "JP"]
                      forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
                    }
                  },
                  {
                    ip_set_reference = {
                      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                    }
                  },
                ]
              }
            }
          }
        }
      },
      {
        name     = "not_not"
        priority = 12
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              not = {
                statement = {
                  geo_match = {
                    country_codes       = ["KR", "JP"]
                    forwarded_ip_header = { enabled = true, name = "X-Client-IP", fallback_behavior = "MATCH" }
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
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "root"]).geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "root"]).geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "root"]).geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the root branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the and branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the or branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the not branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_and"]).and_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_and"]).and_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_and"]).and_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the and_and branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_or"]).and_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_or"]).and_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_or"]).and_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the and_or branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the and_not branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_and"]).or_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_and"]).or_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_and"]).or_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the or_and branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_or"]).or_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_or"]).or_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_or"]).or_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the or_or branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_not"]).or_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_not"]).or_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_not"]).or_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the or_not branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_and"]).not_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_and"]).not_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_and"]).not_statement[0].statement[0].and_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the not_and branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_or"]).not_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_or"]).not_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_or"]).not_statement[0].statement[0].or_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the not_or branch."
  }

  assert {
    condition = alltrue([
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_not"]).not_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR", "JP"]),
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_not"]).not_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Client-IP",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_not"]).not_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "MATCH",
    ])
    error_message = "Geo match must preserve countries and forwarded-IP settings in the not_not branch."
  }
}

run "forwarded_ip_defaults" {
  command = plan

  variables {
    rules = [
      {
        name     = "origin"
        priority = 0
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes = ["KR"]
                    }
                  }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "defaults"
        priority = 1
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes       = ["KR"]
                      forwarded_ip_header = { enabled = true }
                    }
                  }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "disabled"
        priority = 2
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes       = ["KR"]
                      forwarded_ip_header = { enabled = false, name = "X-Ignored-IP", fallback_behavior = "MATCH" }
                    }
                  }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "omitted_enabled"
        priority = 3
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes       = ["KR"]
                      forwarded_ip_header = { name = "X-Ignored-IP" }
                    }
                  }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
      {
        name     = "no_match"
        priority = 4
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes       = ["KR"]
                      forwarded_ip_header = { enabled = true, name = "X-Forwarded-For", fallback_behavior = "NO_MATCH" }
                    }
                  }
                }
              },
              {
                ip_set_reference = {
                  arn = "arn:aws:wafv2:us-east-1:123456789012:regional/ipset/test/12345678-1234-1234-1234-123456789012"
                }
              },
            ]
          }
        }
      },
    ]
  }

  assert {
    condition     = length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "origin"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config) == 0
    error_message = "Geo match must preserve origin forwarded-IP behavior."
  }

  assert {
    condition     = one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "defaults"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Forwarded-For" && one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "defaults"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "NO_MATCH"
    error_message = "Geo match must preserve defaults forwarded-IP behavior."
  }

  assert {
    condition     = length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "disabled"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config) == 0
    error_message = "Geo match must preserve disabled forwarded-IP behavior."
  }

  assert {
    condition     = length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "omitted_enabled"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config) == 0
    error_message = "Geo match must preserve omitted_enabled forwarded-IP behavior."
  }

  assert {
    condition     = one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "no_match"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].header_name == "X-Forwarded-For" && one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "no_match"]).and_statement[0].statement[0].not_statement[0].statement[0].geo_match_statement[0].forwarded_ip_config[0].fallback_behavior == "NO_MATCH"
    error_message = "Geo match must preserve no_match forwarded-IP behavior."
  }
}

run "block_non_korean_admin_requests" {
  command = plan

  variables {
    rules = [
      {
        name     = "block-non-kr-admin"
        priority = 10
        action   = "BLOCK"
        statement = {
          and = {
            statements = [
              {
                byte_match = {
                  search_string         = "/admin/"
                  positional_constraint = "STARTS_WITH"
                  field_to_match = {
                    uri_path = {}
                  }
                }
              },
              {
                not = {
                  statement = {
                    geo_match = {
                      country_codes = ["KR"]
                    }
                  }
                }
              },
            ]
          }
        }
      },
    ]
  }

  assert {
    condition     = length(one(aws_wafv2_web_acl.this.rule).action[0].block) == 1
    error_message = "Matching requests must be blocked."
  }

  assert {
    condition     = length(one(aws_wafv2_web_acl.this.rule).statement[0].and_statement[0].statement) == 2
    error_message = "The AND statement must combine exactly the path and country predicates."
  }

  assert {
    condition     = one(aws_wafv2_web_acl.this.rule).statement[0].and_statement[0].statement[0].byte_match_statement[0].search_string == "/admin/" && one(aws_wafv2_web_acl.this.rule).statement[0].and_statement[0].statement[0].byte_match_statement[0].positional_constraint == "STARTS_WITH"
    error_message = "The path predicate must inspect the /admin/ prefix."
  }

  assert {
    condition     = length(one(aws_wafv2_web_acl.this.rule).statement[0].and_statement[0].statement[0].byte_match_statement[0].field_to_match[0].uri_path) == 1
    error_message = "The byte match must inspect the URI path."
  }

  assert {
    condition     = jsonencode(one(aws_wafv2_web_acl.this.rule).statement[0].and_statement[0].statement[1].not_statement[0].statement[0].geo_match_statement[0].country_codes) == jsonencode(["KR"])
    error_message = "The NOT statement must exclude requests matching KR."
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.default_action[0].allow) == 1
    error_message = "The default action must allow requests that do not match any rule."
  }
}

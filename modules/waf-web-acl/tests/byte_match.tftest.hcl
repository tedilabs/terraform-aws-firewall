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

run "request_components" {
  command = plan

  variables {
    rules = [
      {
        name     = "all_query_arguments"
        priority = 0
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              all_query_arguments = {}
            }
          }
        }
      },
      {
        name     = "method"
        priority = 1
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              method = {}
            }
          }
        }
      },
      {
        name     = "query_string"
        priority = 2
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              query_string = {}
            }
          }
        }
      },
      {
        name     = "uri_path"
        priority = 3
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              uri_path = {}
            }
          }
        }
      },
      {
        name     = "body"
        priority = 4
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              body = { oversize_handling = "MATCH" }
            }
          }
        }
      },
      {
        name     = "body_default"
        priority = 5
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              body = {}
            }
          }
        }
      },
      {
        name     = "header_order"
        priority = 6
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              header_order = { oversize_handling = "NO_MATCH" }
            }
          }
        }
      },
      {
        name     = "ja3_fingerprint"
        priority = 7
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
            positional_constraint = "EXACTLY"
            field_to_match = {
              ja3_fingerprint = { fallback_behavior = "MATCH" }
            }
          }
        }
      },
      {
        name     = "ja4_fingerprint"
        priority = 8
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "t13d1516h2_8daaf6152771_02713d6af862"
            positional_constraint = "EXACTLY"
            field_to_match = {
              ja4_fingerprint = { fallback_behavior = "NO_MATCH" }
            }
          }
        }
      },
      {
        name     = "single_header"
        priority = 9
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              single_header = { name = "user-agent" }
            }
          }
        }
      },
      {
        name     = "single_query_argument"
        priority = 10
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              single_query_argument = { name = "id" }
            }
          }
        }
      },
      {
        name     = "uri_fragment"
        priority = 11
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              uri_fragment = { fallback_behavior = "NO_MATCH" }
            }
          }
        }
      },
      {
        name     = "uri_fragment_default"
        priority = 12
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              uri_fragment = {}
            }
          }
        }
      },
      {
        name     = "cookies_all"
        priority = 13
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              cookies = {
                match_scope       = "VALUE"
                oversize_handling = "MATCH"
                match_pattern = {
                  all = {}
                }
              }
            }
          }
        }
      },
      {
        name     = "cookies_included_cookies"
        priority = 14
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              cookies = {
                match_scope       = "VALUE"
                oversize_handling = "MATCH"
                match_pattern = {
                  included_cookies = ["session"]
                }
              }
            }
          }
        }
      },
      {
        name     = "cookies_excluded_cookies"
        priority = 15
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              cookies = {
                match_scope       = "VALUE"
                oversize_handling = "MATCH"
                match_pattern = {
                  excluded_cookies = ["tracking"]
                }
              }
            }
          }
        }
      },
      {
        name     = "headers_all"
        priority = 16
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              headers = {
                match_scope       = "VALUE"
                oversize_handling = "MATCH"
                match_pattern = {
                  all = {}
                }
              }
            }
          }
        }
      },
      {
        name     = "headers_included_headers"
        priority = 17
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              headers = {
                match_scope       = "VALUE"
                oversize_handling = "MATCH"
                match_pattern = {
                  included_headers = ["session"]
                }
              }
            }
          }
        }
      },
      {
        name     = "headers_excluded_headers"
        priority = 18
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              headers = {
                match_scope       = "VALUE"
                oversize_handling = "MATCH"
                match_pattern = {
                  excluded_headers = ["tracking"]
                }
              }
            }
          }
        }
      },
      {
        name     = "json_all"
        priority = 19
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              json_body = {
                match_scope               = "KEY"
                oversize_handling         = "NO_MATCH"
                invalid_fallback_behavior = "EVALUATE_AS_STRING"
                match_pattern = {
                  all = {}
                }
              }
            }
          }
        }
      },
      {
        name     = "json_included_paths"
        priority = 20
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              json_body = {
                match_scope               = "KEY"
                oversize_handling         = "NO_MATCH"
                invalid_fallback_behavior = "EVALUATE_AS_STRING"
                match_pattern = {
                  included_paths = ["/user/name", "/user/role"]
                }
              }
            }
          }
        }
      },
      {
        name     = "json_defaults"
        priority = 21
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              json_body = {
                match_scope = "ALL"
                match_pattern = {
                  all = {}
                }
              }
            }
          }
        }
      },
      {
        name     = "transforms"
        priority = 22
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "EXACTLY"
            field_to_match = {
              all_query_arguments = {}
            }
            text_transformations = [
              { priority = 10, type = "URL_DECODE" },
              { priority = 20, type = "LOWERCASE" },
            ]
            pre_parse_text_transformations = [
              { priority = 5, type = "REPLACE_SEMICOLONS_WITH_AMPERSANDS" },
              { priority = 15, type = "COMBINE_DUPLICATE_QUERY_ARGS_BY_COMMA" },
            ]
          }
        }
      },
      {
        name     = "position_starts_with"
        priority = 23
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "STARTS_WITH"
            field_to_match = {
              uri_path = {}
            }
          }
        }
      },
      {
        name     = "position_ends_with"
        priority = 24
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "ENDS_WITH"
            field_to_match = {
              uri_path = {}
            }
          }
        }
      },
      {
        name     = "position_contains"
        priority = 25
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "CONTAINS"
            field_to_match = {
              uri_path = {}
            }
          }
        }
      },
      {
        name     = "position_contains_word"
        priority = 26
        action   = "BLOCK"
        statement = {
          byte_match = {
            search_string         = "admin"
            positional_constraint = "CONTAINS_WORD"
            field_to_match = {
              uri_path = {}
            }
          }
        }
      },
    ]
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "all_query_arguments"]).byte_match_statement[0].field_to_match[0].all_query_arguments) == 1,
    ])
    error_message = "Byte match must preserve all_query_arguments request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "method"]).byte_match_statement[0].field_to_match[0].method) == 1,
    ])
    error_message = "Byte match must preserve method request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "query_string"]).byte_match_statement[0].field_to_match[0].query_string) == 1,
    ])
    error_message = "Byte match must preserve query_string request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "uri_path"]).byte_match_statement[0].field_to_match[0].uri_path) == 1,
    ])
    error_message = "Byte match must preserve uri_path request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "body"]).byte_match_statement[0].field_to_match[0].body) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "body"]).byte_match_statement[0].field_to_match[0].body[0].oversize_handling == "MATCH",
    ])
    error_message = "Byte match must preserve body request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "body_default"]).byte_match_statement[0].field_to_match[0].body) == 1,
    ])
    error_message = "Byte match must preserve body_default request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "header_order"]).byte_match_statement[0].field_to_match[0].header_order) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "header_order"]).byte_match_statement[0].field_to_match[0].header_order[0].oversize_handling == "NO_MATCH",
    ])
    error_message = "Byte match must preserve header_order request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "ja3_fingerprint"]).byte_match_statement[0].field_to_match[0].ja3_fingerprint) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "ja3_fingerprint"]).byte_match_statement[0].field_to_match[0].ja3_fingerprint[0].fallback_behavior == "MATCH",
    ])
    error_message = "Byte match must preserve ja3_fingerprint request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "ja4_fingerprint"]).byte_match_statement[0].field_to_match[0].ja4_fingerprint) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "ja4_fingerprint"]).byte_match_statement[0].field_to_match[0].ja4_fingerprint[0].fallback_behavior == "NO_MATCH",
    ])
    error_message = "Byte match must preserve ja4_fingerprint request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "single_header"]).byte_match_statement[0].field_to_match[0].single_header) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "single_header"]).byte_match_statement[0].field_to_match[0].single_header[0].name == "user-agent",
    ])
    error_message = "Byte match must preserve single_header request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "single_query_argument"]).byte_match_statement[0].field_to_match[0].single_query_argument) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "single_query_argument"]).byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "id",
    ])
    error_message = "Byte match must preserve single_query_argument request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "uri_fragment"]).byte_match_statement[0].field_to_match[0].uri_fragment) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "uri_fragment"]).byte_match_statement[0].field_to_match[0].uri_fragment[0].fallback_behavior == "NO_MATCH",
    ])
    error_message = "Byte match must preserve uri_fragment request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "uri_fragment_default"]).byte_match_statement[0].field_to_match[0].uri_fragment) == 1,
    ])
    error_message = "Byte match must preserve uri_fragment_default request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_all"]).byte_match_statement[0].field_to_match[0].cookies) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_all"]).byte_match_statement[0].field_to_match[0].cookies[0].match_scope == "VALUE",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_all"]).byte_match_statement[0].field_to_match[0].cookies[0].oversize_handling == "MATCH",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_all"]).byte_match_statement[0].field_to_match[0].cookies[0].match_pattern) == 1,
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_all"]).byte_match_statement[0].field_to_match[0].cookies[0].match_pattern[0].all) == 1,
    ])
    error_message = "Byte match must preserve cookies_all request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_included_cookies"]).byte_match_statement[0].field_to_match[0].cookies) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_included_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].match_scope == "VALUE",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_included_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].oversize_handling == "MATCH",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_included_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].match_pattern) == 1,
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_included_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].match_pattern[0].included_cookies) == jsonencode(["session"]),
    ])
    error_message = "Byte match must preserve cookies_included_cookies request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_excluded_cookies"]).byte_match_statement[0].field_to_match[0].cookies) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_excluded_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].match_scope == "VALUE",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_excluded_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].oversize_handling == "MATCH",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_excluded_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].match_pattern) == 1,
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "cookies_excluded_cookies"]).byte_match_statement[0].field_to_match[0].cookies[0].match_pattern[0].excluded_cookies) == jsonencode(["tracking"]),
    ])
    error_message = "Byte match must preserve cookies_excluded_cookies request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_all"]).byte_match_statement[0].field_to_match[0].headers) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_all"]).byte_match_statement[0].field_to_match[0].headers[0].match_scope == "VALUE",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_all"]).byte_match_statement[0].field_to_match[0].headers[0].oversize_handling == "MATCH",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_all"]).byte_match_statement[0].field_to_match[0].headers[0].match_pattern) == 1,
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_all"]).byte_match_statement[0].field_to_match[0].headers[0].match_pattern[0].all) == 1,
    ])
    error_message = "Byte match must preserve headers_all request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_included_headers"]).byte_match_statement[0].field_to_match[0].headers) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_included_headers"]).byte_match_statement[0].field_to_match[0].headers[0].match_scope == "VALUE",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_included_headers"]).byte_match_statement[0].field_to_match[0].headers[0].oversize_handling == "MATCH",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_included_headers"]).byte_match_statement[0].field_to_match[0].headers[0].match_pattern) == 1,
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_included_headers"]).byte_match_statement[0].field_to_match[0].headers[0].match_pattern[0].included_headers) == jsonencode(["session"]),
    ])
    error_message = "Byte match must preserve headers_included_headers request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_excluded_headers"]).byte_match_statement[0].field_to_match[0].headers) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_excluded_headers"]).byte_match_statement[0].field_to_match[0].headers[0].match_scope == "VALUE",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_excluded_headers"]).byte_match_statement[0].field_to_match[0].headers[0].oversize_handling == "MATCH",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_excluded_headers"]).byte_match_statement[0].field_to_match[0].headers[0].match_pattern) == 1,
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "headers_excluded_headers"]).byte_match_statement[0].field_to_match[0].headers[0].match_pattern[0].excluded_headers) == jsonencode(["tracking"]),
    ])
    error_message = "Byte match must preserve headers_excluded_headers request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_all"]).byte_match_statement[0].field_to_match[0].json_body) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_all"]).byte_match_statement[0].field_to_match[0].json_body[0].match_scope == "KEY",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_all"]).byte_match_statement[0].field_to_match[0].json_body[0].oversize_handling == "NO_MATCH",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_all"]).byte_match_statement[0].field_to_match[0].json_body[0].invalid_fallback_behavior == "EVALUATE_AS_STRING",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_all"]).byte_match_statement[0].field_to_match[0].json_body[0].match_pattern) == 1,
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_all"]).byte_match_statement[0].field_to_match[0].json_body[0].match_pattern[0].all) == 1,
    ])
    error_message = "Byte match must preserve json_all request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_included_paths"]).byte_match_statement[0].field_to_match[0].json_body) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_included_paths"]).byte_match_statement[0].field_to_match[0].json_body[0].match_scope == "KEY",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_included_paths"]).byte_match_statement[0].field_to_match[0].json_body[0].oversize_handling == "NO_MATCH",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_included_paths"]).byte_match_statement[0].field_to_match[0].json_body[0].invalid_fallback_behavior == "EVALUATE_AS_STRING",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_included_paths"]).byte_match_statement[0].field_to_match[0].json_body[0].match_pattern) == 1,
      jsonencode(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_included_paths"]).byte_match_statement[0].field_to_match[0].json_body[0].match_pattern[0].included_paths) == jsonencode(["/user/name", "/user/role"]),
    ])
    error_message = "Byte match must preserve json_included_paths request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_defaults"]).byte_match_statement[0].field_to_match[0].json_body) == 1,
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_defaults"]).byte_match_statement[0].field_to_match[0].json_body[0].match_scope == "ALL",
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_defaults"]).byte_match_statement[0].field_to_match[0].json_body[0].match_pattern) == 1,
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "json_defaults"]).byte_match_statement[0].field_to_match[0].json_body[0].match_pattern[0].all) == 1,
    ])
    error_message = "Byte match must preserve json_defaults request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "transforms"]).byte_match_statement[0].field_to_match[0].all_query_arguments) == 1,
    ])
    error_message = "Byte match must preserve transforms request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "position_starts_with"]).byte_match_statement[0].field_to_match[0].uri_path) == 1,
    ])
    error_message = "Byte match must preserve position_starts_with request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "position_ends_with"]).byte_match_statement[0].field_to_match[0].uri_path) == 1,
    ])
    error_message = "Byte match must preserve position_ends_with request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "position_contains"]).byte_match_statement[0].field_to_match[0].uri_path) == 1,
    ])
    error_message = "Byte match must preserve position_contains request component settings."
  }

  assert {
    condition = alltrue([
      length(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "position_contains_word"]).byte_match_statement[0].field_to_match[0].uri_path) == 1,
    ])
    error_message = "Byte match must preserve position_contains_word request component settings."
  }

  assert {
    condition = alltrue(flatten([
      for rule in aws_wafv2_web_acl.this.rule : [
        for input in var.rules : alltrue([
          rule.statement[0].byte_match_statement[0].search_string == input.statement.byte_match.search_string,
          rule.statement[0].byte_match_statement[0].positional_constraint == input.statement.byte_match.positional_constraint,
          jsonencode(rule.statement[0].byte_match_statement[0].text_transformation) == jsonencode(toset(try(input.statement.byte_match.text_transformations, [{ priority = 0, type = "NONE" }]))),
          jsonencode(rule.statement[0].byte_match_statement[0].pre_parse_text_transformation) == jsonencode(toset(try(input.statement.byte_match.pre_parse_text_transformations, []))),
        ]) if input.name == rule.name
      ]
    ]))
    error_message = "Every byte match must preserve the search, position, and transformation settings."
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
          byte_match = {
            search_string         = "nested-value"
            positional_constraint = "CONTAINS"
            field_to_match = {
              single_query_argument = { name = "account" }
            }
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
                byte_match = {
                  search_string         = "nested-value"
                  positional_constraint = "CONTAINS"
                  field_to_match = {
                    single_query_argument = { name = "account" }
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
        name     = "or"
        priority = 2
        action   = "BLOCK"
        statement = {
          or = {
            statements = [
              {
                byte_match = {
                  search_string         = "nested-value"
                  positional_constraint = "CONTAINS"
                  field_to_match = {
                    single_query_argument = { name = "account" }
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
        name     = "not"
        priority = 3
        action   = "BLOCK"
        statement = {
          not = {
            statement = {
              byte_match = {
                search_string         = "nested-value"
                positional_constraint = "CONTAINS"
                field_to_match = {
                  single_query_argument = { name = "account" }
                }
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
                      byte_match = {
                        search_string         = "nested-value"
                        positional_constraint = "CONTAINS"
                        field_to_match = {
                          single_query_argument = { name = "account" }
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
                      byte_match = {
                        search_string         = "nested-value"
                        positional_constraint = "CONTAINS"
                        field_to_match = {
                          single_query_argument = { name = "account" }
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
                    byte_match = {
                      search_string         = "nested-value"
                      positional_constraint = "CONTAINS"
                      field_to_match = {
                        single_query_argument = { name = "account" }
                      }
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
                      byte_match = {
                        search_string         = "nested-value"
                        positional_constraint = "CONTAINS"
                        field_to_match = {
                          single_query_argument = { name = "account" }
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
                      byte_match = {
                        search_string         = "nested-value"
                        positional_constraint = "CONTAINS"
                        field_to_match = {
                          single_query_argument = { name = "account" }
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
                    byte_match = {
                      search_string         = "nested-value"
                      positional_constraint = "CONTAINS"
                      field_to_match = {
                        single_query_argument = { name = "account" }
                      }
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
                    byte_match = {
                      search_string         = "nested-value"
                      positional_constraint = "CONTAINS"
                      field_to_match = {
                        single_query_argument = { name = "account" }
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
                    byte_match = {
                      search_string         = "nested-value"
                      positional_constraint = "CONTAINS"
                      field_to_match = {
                        single_query_argument = { name = "account" }
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
                  byte_match = {
                    search_string         = "nested-value"
                    positional_constraint = "CONTAINS"
                    field_to_match = {
                      single_query_argument = { name = "account" }
                    }
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
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "root"]).byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "root"]).byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "root"]).byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "root"]).byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the root branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and"]).and_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the and branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or"]).or_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the or branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not"]).not_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the not branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_and"]).and_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_and"]).and_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_and"]).and_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_and"]).and_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the and_and branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_or"]).and_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_or"]).and_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_or"]).and_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_or"]).and_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the and_or branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "and_not"]).and_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the and_not branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_and"]).or_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_and"]).or_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_and"]).or_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_and"]).or_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the or_and branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_or"]).or_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_or"]).or_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_or"]).or_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_or"]).or_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the or_or branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_not"]).or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_not"]).or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_not"]).or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "or_not"]).or_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the or_not branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_and"]).not_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_and"]).not_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_and"]).not_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_and"]).not_statement[0].statement[0].and_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the not_and branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_or"]).not_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_or"]).not_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_or"]).not_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_or"]).not_statement[0].statement[0].or_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the not_or branch."
  }

  assert {
    condition = alltrue([
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_not"]).not_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].search_string == "nested-value",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_not"]).not_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].positional_constraint == "CONTAINS",
      one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_not"]).not_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].field_to_match[0].single_query_argument[0].name == "account",
      one(one([for rule in aws_wafv2_web_acl.this.rule : rule.statement[0] if rule.name == "not_not"]).not_statement[0].statement[0].not_statement[0].statement[0].byte_match_statement[0].text_transformation).type == "NONE",
    ])
    error_message = "Byte match must preserve all properties in the not_not branch."
  }
}

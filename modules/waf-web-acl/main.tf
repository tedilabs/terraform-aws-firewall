locals {
  metadata = {
    package = "terraform-aws-firewall"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = "${var.is_global ? "CLOUDFRONT" : "REGIONAL"}/${var.name}"
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

locals {
  resource_config_enabled = anytrue([
    var.resource_config.api_gateway != null,
    var.resource_config.app_runner_service != null,
    var.resource_config.cloudfront != null,
    var.resource_config.cognito_user_pool != null,
    var.resource_config.verified_access_instance != null,
  ])
}

###################################################
# Web ACL for WAF (Web Application Firewall)
###################################################

resource "aws_wafv2_web_acl" "this" {
  region = var.region

  name        = var.name
  description = var.description

  scope = var.is_global ? "CLOUDFRONT" : "REGIONAL"


  ## Rules
  default_action {
    dynamic "allow" {
      for_each = var.default_action == "ALLOW" ? ["go"] : []

      content {
        dynamic "custom_request_handling" {
          for_each = var.custom_request != null ? [var.custom_request] : []
          iterator = request

          content {
            dynamic "insert_header" {
              for_each = request.value.headers
              iterator = header

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
      }
    }

    dynamic "block" {
      for_each = var.default_action == "BLOCK" ? ["go"] : []

      content {
        dynamic "custom_response" {
          for_each = var.custom_response != null ? [var.custom_response] : []
          iterator = response

          content {
            response_code = response.value.status_code

            dynamic "response_header" {
              for_each = response.value.headers
              iterator = header

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "rule_label" {
        for_each = try(rule.value.labels, [])
        iterator = label

        content {
          name = label.value
        }
      }

      statement {
        ## Leaf Statements
        dynamic "asn_match_statement" {
          for_each = try(rule.value.statement.asn_match, null) != null ? [rule.value.statement.asn_match] : []
          iterator = asn_match

          content {
            asn_list = asn_match.value.asn_list

            dynamic "forwarded_ip_config" {
              for_each = try(asn_match.value.forwarded_ip_header.enabled, false) ? [asn_match.value.forwarded_ip_header] : []
              iterator = header

              content {
                header_name       = try(header.value.name, "X-Forwarded-For")
                fallback_behavior = try(header.value.fallback_behavior, "NO_MATCH")
              }
            }
          }
        }

        dynamic "byte_match_statement" {
          for_each = try(rule.value.statement.byte_match, null) != null ? [rule.value.statement.byte_match] : []
          iterator = byte_match

          content {
            positional_constraint = byte_match.value.positional_constraint
            search_string         = byte_match.value.search_string

            field_to_match {
              dynamic "all_query_arguments" {
                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                content {}
              }
              dynamic "method" {
                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                content {}
              }
              dynamic "query_string" {
                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                content {}
              }
              dynamic "uri_path" {
                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                content {}
              }
              dynamic "body" {
                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                content {
                  oversize_handling = try(body.value.oversize_handling, null)
                }
              }
              dynamic "header_order" {
                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                content {
                  oversize_handling = header_order.value.oversize_handling
                }
              }
              dynamic "ja3_fingerprint" {
                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                content {
                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                }
              }
              dynamic "ja4_fingerprint" {
                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                content {
                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                }
              }
              dynamic "single_header" {
                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                content {
                  name = single_header.value.name
                }
              }
              dynamic "single_query_argument" {
                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                content {
                  name = single_query_argument.value.name
                }
              }
              dynamic "uri_fragment" {
                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                content {
                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                }
              }
              dynamic "cookies" {
                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                content {
                  match_scope       = cookies.value.match_scope
                  oversize_handling = cookies.value.oversize_handling

                  match_pattern {
                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                    dynamic "all" {
                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                      content {}
                    }
                  }
                }
              }
              dynamic "headers" {
                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                content {
                  match_scope       = headers.value.match_scope
                  oversize_handling = headers.value.oversize_handling

                  match_pattern {
                    included_headers = try(headers.value.match_pattern.included_headers, null)
                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                    dynamic "all" {
                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                      content {}
                    }
                  }
                }
              }
              dynamic "json_body" {
                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                content {
                  match_scope               = json_body.value.match_scope
                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                  oversize_handling         = try(json_body.value.oversize_handling, null)

                  match_pattern {
                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                    dynamic "all" {
                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                      content {}
                    }
                  }
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
              iterator = transformation

              content {
                priority = transformation.value.priority
                type     = transformation.value.type
              }
            }

            dynamic "pre_parse_text_transformation" {
              for_each = try(byte_match.value.pre_parse_text_transformations, [])
              iterator = transformation

              content {
                priority = transformation.value.priority
                type     = transformation.value.type
              }
            }
          }
        }

        dynamic "geo_match_statement" {
          for_each = try(rule.value.statement.geo_match, null) != null ? [rule.value.statement.geo_match] : []
          iterator = geo_match

          content {
            country_codes = geo_match.value.country_codes

            dynamic "forwarded_ip_config" {
              for_each = try(geo_match.value.forwarded_ip_header.enabled, false) ? [geo_match.value.forwarded_ip_header] : []
              iterator = header

              content {
                header_name       = try(header.value.name, "X-Forwarded-For")
                fallback_behavior = try(header.value.fallback_behavior, "NO_MATCH")
              }
            }
          }
        }

        dynamic "ip_set_reference_statement" {
          for_each = try(rule.value.statement.ip_set_reference, null) != null ? [rule.value.statement.ip_set_reference] : []
          iterator = ip_set_reference

          content {
            arn = ip_set_reference.value.arn

            dynamic "ip_set_forwarded_ip_config" {
              for_each = try(ip_set_reference.value.forwarded_ip_header.enabled, false) ? [ip_set_reference.value.forwarded_ip_header] : []
              iterator = header

              content {
                header_name       = try(header.value.name, "X-Forwarded-For")
                position          = try(header.value.position, "FIRST")
                fallback_behavior = try(header.value.fallback_behavior, "NO_MATCH")
              }
            }
          }
        }

        dynamic "label_match_statement" {
          for_each = try(rule.value.statement.label_match, null) != null ? [rule.value.statement.label_match] : []
          iterator = label_match

          content {
            scope = label_match.value.scope
            key   = label_match.value.key
          }
        }


        # Logical operators
        dynamic "and_statement" {
          for_each = try(rule.value.statement.and, null) != null ? [rule.value.statement.and] : []
          iterator = and

          content {
            dynamic "statement" {
              for_each = try(and.value.statements, [])

              content {
                # Nested simple statements
                dynamic "byte_match_statement" {
                  for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                  iterator = byte_match

                  content {
                    positional_constraint = byte_match.value.positional_constraint
                    search_string         = byte_match.value.search_string

                    field_to_match {
                      dynamic "all_query_arguments" {
                        for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "method" {
                        for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "query_string" {
                        for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "uri_path" {
                        for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "body" {
                        for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                        content {
                          oversize_handling = try(body.value.oversize_handling, null)
                        }
                      }
                      dynamic "header_order" {
                        for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                        content {
                          oversize_handling = header_order.value.oversize_handling
                        }
                      }
                      dynamic "ja3_fingerprint" {
                        for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                        content {
                          fallback_behavior = ja3_fingerprint.value.fallback_behavior
                        }
                      }
                      dynamic "ja4_fingerprint" {
                        for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                        content {
                          fallback_behavior = ja4_fingerprint.value.fallback_behavior
                        }
                      }
                      dynamic "single_header" {
                        for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                        content {
                          name = single_header.value.name
                        }
                      }
                      dynamic "single_query_argument" {
                        for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                        content {
                          name = single_query_argument.value.name
                        }
                      }
                      dynamic "uri_fragment" {
                        for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                        content {
                          fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                        }
                      }
                      dynamic "cookies" {
                        for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                        content {
                          match_scope       = cookies.value.match_scope
                          oversize_handling = cookies.value.oversize_handling

                          match_pattern {
                            included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                            excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                            dynamic "all" {
                              for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                      dynamic "headers" {
                        for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                        content {
                          match_scope       = headers.value.match_scope
                          oversize_handling = headers.value.oversize_handling

                          match_pattern {
                            included_headers = try(headers.value.match_pattern.included_headers, null)
                            excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                            dynamic "all" {
                              for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                      dynamic "json_body" {
                        for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                        content {
                          match_scope               = json_body.value.match_scope
                          invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                          oversize_handling         = try(json_body.value.oversize_handling, null)

                          match_pattern {
                            included_paths = try(json_body.value.match_pattern.included_paths, null)

                            dynamic "all" {
                              for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                    }

                    dynamic "text_transformation" {
                      for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                      iterator = transformation

                      content {
                        priority = transformation.value.priority
                        type     = transformation.value.type
                      }
                    }

                    dynamic "pre_parse_text_transformation" {
                      for_each = try(byte_match.value.pre_parse_text_transformations, [])
                      iterator = transformation

                      content {
                        priority = transformation.value.priority
                        type     = transformation.value.type
                      }
                    }
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }


                # Nested logical operators (2nd level)
                dynamic "and_statement" {
                  for_each = can(statement.value.and) ? [statement.value.and] : []

                  content {
                    dynamic "statement" {
                      for_each = try(and_statement.value.statements, [])

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }

                dynamic "or_statement" {
                  for_each = can(statement.value.or) ? [statement.value.or] : []

                  content {
                    dynamic "statement" {
                      for_each = try(or_statement.value.statements, [])

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }

                dynamic "not_statement" {
                  for_each = can(statement.value.not) ? [statement.value.not] : []

                  content {
                    dynamic "statement" {
                      for_each = can(not_statement.value.statement) ? [not_statement.value.statement] : []

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "or_statement" {
          for_each = try(rule.value.statement.or, null) != null ? [rule.value.statement.or] : []
          iterator = or

          content {
            dynamic "statement" {
              for_each = try(or.value.statements, [])

              content {
                # Nested simple statements
                dynamic "byte_match_statement" {
                  for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                  iterator = byte_match

                  content {
                    positional_constraint = byte_match.value.positional_constraint
                    search_string         = byte_match.value.search_string

                    field_to_match {
                      dynamic "all_query_arguments" {
                        for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "method" {
                        for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "query_string" {
                        for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "uri_path" {
                        for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "body" {
                        for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                        content {
                          oversize_handling = try(body.value.oversize_handling, null)
                        }
                      }
                      dynamic "header_order" {
                        for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                        content {
                          oversize_handling = header_order.value.oversize_handling
                        }
                      }
                      dynamic "ja3_fingerprint" {
                        for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                        content {
                          fallback_behavior = ja3_fingerprint.value.fallback_behavior
                        }
                      }
                      dynamic "ja4_fingerprint" {
                        for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                        content {
                          fallback_behavior = ja4_fingerprint.value.fallback_behavior
                        }
                      }
                      dynamic "single_header" {
                        for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                        content {
                          name = single_header.value.name
                        }
                      }
                      dynamic "single_query_argument" {
                        for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                        content {
                          name = single_query_argument.value.name
                        }
                      }
                      dynamic "uri_fragment" {
                        for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                        content {
                          fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                        }
                      }
                      dynamic "cookies" {
                        for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                        content {
                          match_scope       = cookies.value.match_scope
                          oversize_handling = cookies.value.oversize_handling

                          match_pattern {
                            included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                            excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                            dynamic "all" {
                              for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                      dynamic "headers" {
                        for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                        content {
                          match_scope       = headers.value.match_scope
                          oversize_handling = headers.value.oversize_handling

                          match_pattern {
                            included_headers = try(headers.value.match_pattern.included_headers, null)
                            excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                            dynamic "all" {
                              for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                      dynamic "json_body" {
                        for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                        content {
                          match_scope               = json_body.value.match_scope
                          invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                          oversize_handling         = try(json_body.value.oversize_handling, null)

                          match_pattern {
                            included_paths = try(json_body.value.match_pattern.included_paths, null)

                            dynamic "all" {
                              for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                    }

                    dynamic "text_transformation" {
                      for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                      iterator = transformation

                      content {
                        priority = transformation.value.priority
                        type     = transformation.value.type
                      }
                    }

                    dynamic "pre_parse_text_transformation" {
                      for_each = try(byte_match.value.pre_parse_text_transformations, [])
                      iterator = transformation

                      content {
                        priority = transformation.value.priority
                        type     = transformation.value.type
                      }
                    }
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }


                # Nested logical operators (2nd level)
                dynamic "and_statement" {
                  for_each = can(statement.value.and) ? [statement.value.and] : []

                  content {
                    dynamic "statement" {
                      for_each = try(and_statement.value.statements, [])

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }

                dynamic "or_statement" {
                  for_each = can(statement.value.or) ? [statement.value.or] : []

                  content {
                    dynamic "statement" {
                      for_each = try(or_statement.value.statements, [])

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }

                dynamic "not_statement" {
                  for_each = can(statement.value.not) ? [statement.value.not] : []

                  content {
                    dynamic "statement" {
                      for_each = can(not_statement.value.statement) ? [not_statement.value.statement] : []

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "not_statement" {
          for_each = try(rule.value.statement.not, null) != null ? [rule.value.statement.not] : []
          iterator = not

          content {
            dynamic "statement" {
              for_each = can(not.value.statement) ? [not.value.statement] : []

              content {
                # Nested simple statements
                dynamic "byte_match_statement" {
                  for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                  iterator = byte_match

                  content {
                    positional_constraint = byte_match.value.positional_constraint
                    search_string         = byte_match.value.search_string

                    field_to_match {
                      dynamic "all_query_arguments" {
                        for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "method" {
                        for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "query_string" {
                        for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "uri_path" {
                        for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                        content {}
                      }
                      dynamic "body" {
                        for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                        content {
                          oversize_handling = try(body.value.oversize_handling, null)
                        }
                      }
                      dynamic "header_order" {
                        for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                        content {
                          oversize_handling = header_order.value.oversize_handling
                        }
                      }
                      dynamic "ja3_fingerprint" {
                        for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                        content {
                          fallback_behavior = ja3_fingerprint.value.fallback_behavior
                        }
                      }
                      dynamic "ja4_fingerprint" {
                        for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                        content {
                          fallback_behavior = ja4_fingerprint.value.fallback_behavior
                        }
                      }
                      dynamic "single_header" {
                        for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                        content {
                          name = single_header.value.name
                        }
                      }
                      dynamic "single_query_argument" {
                        for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                        content {
                          name = single_query_argument.value.name
                        }
                      }
                      dynamic "uri_fragment" {
                        for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                        content {
                          fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                        }
                      }
                      dynamic "cookies" {
                        for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                        content {
                          match_scope       = cookies.value.match_scope
                          oversize_handling = cookies.value.oversize_handling

                          match_pattern {
                            included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                            excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                            dynamic "all" {
                              for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                      dynamic "headers" {
                        for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                        content {
                          match_scope       = headers.value.match_scope
                          oversize_handling = headers.value.oversize_handling

                          match_pattern {
                            included_headers = try(headers.value.match_pattern.included_headers, null)
                            excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                            dynamic "all" {
                              for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                      dynamic "json_body" {
                        for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                        content {
                          match_scope               = json_body.value.match_scope
                          invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                          oversize_handling         = try(json_body.value.oversize_handling, null)

                          match_pattern {
                            included_paths = try(json_body.value.match_pattern.included_paths, null)

                            dynamic "all" {
                              for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                              content {}
                            }
                          }
                        }
                      }
                    }

                    dynamic "text_transformation" {
                      for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                      iterator = transformation

                      content {
                        priority = transformation.value.priority
                        type     = transformation.value.type
                      }
                    }

                    dynamic "pre_parse_text_transformation" {
                      for_each = try(byte_match.value.pre_parse_text_transformations, [])
                      iterator = transformation

                      content {
                        priority = transformation.value.priority
                        type     = transformation.value.type
                      }
                    }
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                  content {
                    arn = ip_set_reference_statement.value.arn
                  }
                }


                # Nested logical operators (2nd level)
                dynamic "and_statement" {
                  for_each = can(statement.value.and) ? [statement.value.and] : []

                  content {
                    dynamic "statement" {
                      for_each = try(and_statement.value.statements, [])

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }

                dynamic "or_statement" {
                  for_each = can(statement.value.or) ? [statement.value.or] : []

                  content {
                    dynamic "statement" {
                      for_each = try(or_statement.value.statements, [])

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }

                dynamic "not_statement" {
                  for_each = can(statement.value.not) ? [statement.value.not] : []

                  content {
                    dynamic "statement" {
                      for_each = can(not_statement.value.statement) ? [not_statement.value.statement] : []

                      content {
                        # 3rd level simple statements
                        dynamic "byte_match_statement" {
                          for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                          iterator = byte_match

                          content {
                            positional_constraint = byte_match.value.positional_constraint
                            search_string         = byte_match.value.search_string

                            field_to_match {
                              dynamic "all_query_arguments" {
                                for_each = try(byte_match.value.field_to_match.all_query_arguments, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "method" {
                                for_each = try(byte_match.value.field_to_match.method, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "query_string" {
                                for_each = try(byte_match.value.field_to_match.query_string, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "uri_path" {
                                for_each = try(byte_match.value.field_to_match.uri_path, null) != null ? ["go"] : []

                                content {}
                              }
                              dynamic "body" {
                                for_each = try(byte_match.value.field_to_match.body, null) != null ? [byte_match.value.field_to_match.body] : []

                                content {
                                  oversize_handling = try(body.value.oversize_handling, null)
                                }
                              }
                              dynamic "header_order" {
                                for_each = try(byte_match.value.field_to_match.header_order, null) != null ? [byte_match.value.field_to_match.header_order] : []

                                content {
                                  oversize_handling = header_order.value.oversize_handling
                                }
                              }
                              dynamic "ja3_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja3_fingerprint, null) != null ? [byte_match.value.field_to_match.ja3_fingerprint] : []

                                content {
                                  fallback_behavior = ja3_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "ja4_fingerprint" {
                                for_each = try(byte_match.value.field_to_match.ja4_fingerprint, null) != null ? [byte_match.value.field_to_match.ja4_fingerprint] : []

                                content {
                                  fallback_behavior = ja4_fingerprint.value.fallback_behavior
                                }
                              }
                              dynamic "single_header" {
                                for_each = try(byte_match.value.field_to_match.single_header, null) != null ? [byte_match.value.field_to_match.single_header] : []

                                content {
                                  name = single_header.value.name
                                }
                              }
                              dynamic "single_query_argument" {
                                for_each = try(byte_match.value.field_to_match.single_query_argument, null) != null ? [byte_match.value.field_to_match.single_query_argument] : []

                                content {
                                  name = single_query_argument.value.name
                                }
                              }
                              dynamic "uri_fragment" {
                                for_each = try(byte_match.value.field_to_match.uri_fragment, null) != null ? [byte_match.value.field_to_match.uri_fragment] : []

                                content {
                                  fallback_behavior = try(uri_fragment.value.fallback_behavior, null)
                                }
                              }
                              dynamic "cookies" {
                                for_each = try(byte_match.value.field_to_match.cookies, null) != null ? [byte_match.value.field_to_match.cookies] : []

                                content {
                                  match_scope       = cookies.value.match_scope
                                  oversize_handling = cookies.value.oversize_handling

                                  match_pattern {
                                    included_cookies = try(cookies.value.match_pattern.included_cookies, null)
                                    excluded_cookies = try(cookies.value.match_pattern.excluded_cookies, null)

                                    dynamic "all" {
                                      for_each = try(cookies.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "headers" {
                                for_each = try(byte_match.value.field_to_match.headers, null) != null ? [byte_match.value.field_to_match.headers] : []

                                content {
                                  match_scope       = headers.value.match_scope
                                  oversize_handling = headers.value.oversize_handling

                                  match_pattern {
                                    included_headers = try(headers.value.match_pattern.included_headers, null)
                                    excluded_headers = try(headers.value.match_pattern.excluded_headers, null)

                                    dynamic "all" {
                                      for_each = try(headers.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                              dynamic "json_body" {
                                for_each = try(byte_match.value.field_to_match.json_body, null) != null ? [byte_match.value.field_to_match.json_body] : []

                                content {
                                  match_scope               = json_body.value.match_scope
                                  invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)
                                  oversize_handling         = try(json_body.value.oversize_handling, null)

                                  match_pattern {
                                    included_paths = try(json_body.value.match_pattern.included_paths, null)

                                    dynamic "all" {
                                      for_each = try(json_body.value.match_pattern.all, null) != null ? ["go"] : []

                                      content {}
                                    }
                                  }
                                }
                              }
                            }

                            dynamic "text_transformation" {
                              for_each = try(byte_match.value.text_transformations, [{ priority = 0, type = "NONE" }])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }

                            dynamic "pre_parse_text_transformation" {
                              for_each = try(byte_match.value.pre_parse_text_transformations, [])
                              iterator = transformation

                              content {
                                priority = transformation.value.priority
                                type     = transformation.value.type
                              }
                            }
                          }
                        }

                        dynamic "ip_set_reference_statement" {
                          for_each = can(statement.value.ip_set_reference) ? [statement.value.ip_set_reference] : []

                          content {
                            arn = ip_set_reference_statement.value.arn
                          }
                        }

                      }
                    }
                  }
                }
              }
            }
          }
        }
      }


      ## Action
      dynamic "action" {
        for_each = [rule.value.action]

        content {
          dynamic "allow" {
            for_each = action.value == "ALLOW" ? ["go"] : []

            content {
              dynamic "custom_request_handling" {
                for_each = try(rule.value.custom_request, null) != null ? [rule.value.custom_request] : []
                iterator = request

                content {
                  dynamic "insert_header" {
                    for_each = try(request.value.headers, [])
                    iterator = header

                    content {
                      name  = header.value.name
                      value = header.value.value
                    }
                  }
                }
              }
            }
          }

          dynamic "block" {
            for_each = action.value == "BLOCK" ? ["go"] : []

            content {
              dynamic "custom_response" {
                for_each = try(rule.value.custom_response, null) != null ? [rule.value.custom_response] : []
                iterator = response

                content {
                  response_code = response.value.status_code

                  dynamic "response_header" {
                    for_each = try(response.value.headers, [])
                    iterator = header

                    content {
                      name  = header.value.name
                      value = header.value.value
                    }
                  }
                }
              }
            }
          }

          dynamic "captcha" {
            for_each = action.value == "CAPTCHA" ? ["go"] : []

            content {
              dynamic "custom_request_handling" {
                for_each = try(rule.value.custom_request, null) != null ? [rule.value.custom_request] : []
                iterator = request

                content {
                  dynamic "insert_header" {
                    for_each = try(request.value.headers, [])
                    iterator = header

                    content {
                      name  = header.value.name
                      value = header.value.value
                    }
                  }
                }
              }
            }
          }

          dynamic "challenge" {
            for_each = action.value == "CHALLENGE" ? ["go"] : []

            content {
              dynamic "custom_request_handling" {
                for_each = try(rule.value.custom_request, null) != null ? [rule.value.custom_request] : []
                iterator = request

                content {
                  dynamic "insert_header" {
                    for_each = try(request.value.headers, [])
                    iterator = header

                    content {
                      name  = header.value.name
                      value = header.value.value
                    }
                  }
                }
              }
            }
          }

          dynamic "count" {
            for_each = action.value == "COUNT" ? ["go"] : []

            content {
              dynamic "custom_request_handling" {
                for_each = try(rule.value.custom_request, null) != null ? [rule.value.custom_request] : []
                iterator = request

                content {
                  dynamic "insert_header" {
                    for_each = try(request.value.headers, [])
                    iterator = header

                    content {
                      name  = header.value.name
                      value = header.value.value
                    }
                  }
                }
              }
            }
          }
        }
      }


      ## Token Configuration
      dynamic "captcha_config" {
        for_each = try(rule.value.token_config.captcha, null) != null ? [rule.value.token_config.captcha] : []
        iterator = captcha

        content {
          immunity_time_property {
            immunity_time = captcha.value.immunity_time
          }
        }
      }
      dynamic "challenge_config" {
        for_each = try(rule.value.token_config.challenge, null) != null ? [rule.value.token_config.challenge] : []
        iterator = challenge

        content {
          immunity_time_property {
            immunity_time = challenge.value.immunity_time
          }
        }
      }


      ## Observability
      visibility_config {
        cloudwatch_metrics_enabled = (try(rule.value.observability.cloudwatch_metrics.enabled, null) != null
          ? rule.value.observability.cloudwatch_metrics.enabled
          : var.observability.cloudwatch_metrics.enabled
        )
        metric_name = (try(rule.value.observability.cloudwatch_metrics.metric_name, null) != null
          ? rule.value.observability.cloudwatch_metrics.metric_name
          : rule.value.name
        )

        sampled_requests_enabled = (try(rule.value.observability.request_sampling.enabled, null) != null
          ? rule.value.observability.request_sampling.enabled
          : var.observability.request_sampling.enabled
        )
      }
    }
  }

  ## Token Configuration
  token_domains = var.token_config.token_domains

  dynamic "captcha_config" {
    for_each = var.token_config.captcha != null ? [var.token_config.captcha] : []
    iterator = captcha

    content {
      immunity_time_property {
        immunity_time = captcha.value.default_immunity_time
      }
    }
  }
  dynamic "challenge_config" {
    for_each = var.token_config.challenge != null ? [var.token_config.challenge] : []
    iterator = challenge

    content {
      immunity_time_property {
        immunity_time = challenge.value.default_immunity_time
      }
    }
  }


  ## Observability
  visibility_config {
    cloudwatch_metrics_enabled = var.observability.cloudwatch_metrics.enabled
    metric_name                = coalesce(var.observability.cloudwatch_metrics.metric_name, var.name)

    sampled_requests_enabled = var.observability.request_sampling.enabled
  }


  ## Resourcees
  dynamic "association_config" {
    for_each = local.resource_config_enabled ? [var.resource_config] : []
    iterator = config

    content {
      request_body {
        dynamic "api_gateway" {
          for_each = config.value.api_gateway != null ? [config.value.api_gateway] : []

          content {
            default_size_inspection_limit = api_gateway.value.web_request_body_inspection_size_limit
          }
        }
        dynamic "app_runner_service" {
          for_each = config.value.app_runner_service != null ? [config.value.app_runner_service] : []

          content {
            default_size_inspection_limit = app_runner_service.value.web_request_body_inspection_size_limit
          }
        }
        dynamic "cloudfront" {
          for_each = config.value.cloudfront != null ? [config.value.cloudfront] : []

          content {
            default_size_inspection_limit = cloudfront.value.web_request_body_inspection_size_limit
          }
        }
        dynamic "cognito_user_pool" {
          for_each = config.value.cognito_user_pool != null ? [config.value.cognito_user_pool] : []

          content {
            default_size_inspection_limit = cognito_user_pool.value.web_request_body_inspection_size_limit
          }
        }
        dynamic "verified_access_instance" {
          for_each = config.value.verified_access_instance != null ? [config.value.verified_access_instance] : []

          content {
            default_size_inspection_limit = verified_access_instance.value.web_request_body_inspection_size_limit
          }
        }
      }
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    local.module_tags,
    var.tags,
  )
}

locals {
  metadata = {
    package = "terraform-aws-firewall"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
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
              for_each = can(and.value.statements) ? and.value.statements : []

              content {
                # Nested simple statements
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
                      for_each = can(and_statement.value.statements) ? and_statement.value.statements : []

                      content {
                        # 3rd level simple statements
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
                      for_each = can(or_statement.value.statements) ? or_statement.value.statements : []

                      content {
                        # 3rd level simple statements
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
              for_each = can(or.value.statements) ? or.value.statements : []

              content {
                # Nested simple statements
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
                      for_each = can(and_statement.value.statements) ? and_statement.value.statements : []

                      content {
                        # 3rd level simple statements
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
                      for_each = can(or_statement.value.statements) ? or_statement.value.statements : []

                      content {
                        # 3rd level simple statements
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
                      for_each = can(and_statement.value.statements) ? and_statement.value.statements : []

                      content {
                        # 3rd level simple statements
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
                      for_each = can(or_statement.value.statements) ? or_statement.value.statements : []

                      content {
                        # 3rd level simple statements
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
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}

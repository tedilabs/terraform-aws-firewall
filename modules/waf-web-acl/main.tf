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

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "ALLOW" ? ["go"] : []

      content {
        dynamic "custom_request_handling" {
          for_each = length(var.custom_request.headers) > 0 ? ["go"] : []

          content {
            dynamic "insert_header" {
              for_each = var.custom_request.headers
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
          for_each = var.custom_response != null ? ["go"] : []

          content {
            response_code = var.custom_response.status_code

            dynamic "response_header" {
              for_each = var.custom_response.headers
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

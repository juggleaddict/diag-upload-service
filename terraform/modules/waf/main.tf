module "label" {
  source = "cloudposse/label/null"


  stage     = var.env
  namespace = var.service_name
  name      = "waf"
  delimiter = "-"
  tags      = local.default_tags

}
module "waf" {
  source = "cloudposse/waf/aws"

  scope = "CLOUDFRONT"
  geo_match_statement_rules = [
    {
      name     = "rule-11"
      action   = "allow"
      priority = 11

      statement = {
        country_codes = ["US", "CA"]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = false
        metric_name                = "rule-11-metric"
      }
    }
  ]

  managed_rule_group_statement_rules = [
    {
      name            = "rule-20"
      override_action = "count"
      priority        = 20

      statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule = [
          "NoUserAgent_HEADER"
        ]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
        metric_name                = "rule-20-metric"
      }
    }
  ]


  rate_based_statement_rules = [
    {
      name     = "rule-40"
      action   = "block"
      priority = 40

      statement = {
        limit              = 100
        aggregate_key_type = "IP"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
        metric_name                = "rule-40-metric"
      }
    }
  ]

  size_constraint_statement_rules = [
    {
      name     = "rule-50"
      action   = "block"
      priority = 50

      statement = {
        comparison_operator = "GT"
        size                = 15

        field_to_match = {
          all_query_arguments = {}
        }

        text_transformation = [
          {
            type     = "COMPRESS_WHITE_SPACE"
            priority = 1
          }
        ]

      }

      visibility_config = {
        cloudwatch_metrics_enabled = false
        sampled_requests_enabled   = false
        metric_name                = "rule-50-metric"
      }
    }
    #    {
    #      name     = "rule-60"
    #      action   = "block"
    #      priority = 60
    #
    #      statement = {
    #        comparison_operator = "GT"
    #        size                = 20000
    #
    #        field_to_match = {
    #          body = {}
    #        }
    #
    #        text_transformation = [
    #          {
    #            type     = "COMPRESS_WHITE_SPACE"
    #            priority = 1
    #          }
    #        ]
    #      }
    #
    #      visibility_config = {
    #        cloudwatch_metrics_enabled = false
    #        sampled_requests_enabled   = false
    #        metric_name                = "rule-60-metric"
    #      }
    #    }
  ]


  context = module.label.context
}
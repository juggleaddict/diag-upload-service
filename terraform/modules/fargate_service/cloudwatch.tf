resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${var.service_name}-${var.env}"
  tags              = merge(local.default_tags, {})
  retention_in_days = 14
}

resource "aws_resourcegroups_group" "service" {
  name = "${var.service_name}-${var.env}"
  tags = merge(local.default_tags, {})

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "service",
      "Values": ["${var.service_name}"]
    },
    {
      "Key": "env",
      "Values": ["${var.env}"]
    }
  ]
}
JSON
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "CloudWatch-Default-${var.service_name}-${var.env}"
  dashboard_body = <<JSON
  {
    "widgets" : [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 10,
        "width" : 10,
        "height" : 5,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "stat" : "Sum",
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.main.arn_suffix}"]
          ],
          "region" : "${var.region}"
          
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 10,
        "height" : 5,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.service_name}-${var.env}", "ClusterName", "${var.service_name}-${var.env}"]
          ],
          "region" : "${var.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 5,
        "width" : 10,
        "height" : 5,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "${var.service_name}-${var.env}", "ClusterName", "${var.service_name}-${var.env}"]
          ],
          "region" : "${var.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 10,
        "y" : 0,
        "width" : 10,
        "height" : 5,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "stat" : "Average",
          "metrics" : [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_lb.main.arn_suffix}"]
          ],
          "region" : "${var.region}"
        }
      },
      {
        "type" : "metric",
        "x" : 10,
        "y" : 5,
        "width" : 10,
        "height" : 5,
        "properties" : {
          "view" : "timeSeries",
          "stacked" : false,
          "title": "Error Rate (%)",
          "stat" : "Sum",
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.main.arn_suffix}",{"id":"m1","visible":false}],
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", "${aws_lb.main.arn_suffix}",{"id":"m2","visible":false}],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_lb.main.arn_suffix}",{"id":"m3","visible":false}],
            [{"expression": "(m2+m3)/m1*100", "label":"Error Rate", "id":"e1"}]
          ],
          "region" : "${var.region}"
        }
      },
      {
        "type" : "log",
        "x" : 10,
        "y" : 10,
        "width" : 10,
        "height" : 5,
        "properties" : {
          "title": "application logs",
          "view" : "table",
          "query" : "SOURCE '/ecs/${var.service_name}-${var.env}' | fields @timestamp, @message \n| sort @timestamp desc \n| limit 20",
          "region" : "${var.region}"
        }
      }
    ]
  }
JSON
}
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
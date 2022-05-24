resource "aws_lb" "main" {
  name                       = "${var.service_name}-${var.env}"
  security_groups            = [aws_security_group.lb.id]
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  subnets                    = [for subnet in aws_subnet.public : subnet.id]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    enabled = true
  }

  tags = merge(local.default_tags, {})
}

resource "aws_lb_target_group" "main" {
  name        = "${var.service_name}-${var.env}"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.main.id
  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  tags = merge(local.default_tags, {})

}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Auth Failed"
      status_code  = "401"
    }
  }
}


resource "aws_lb_listener_rule" "cloudfront" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    http_header {
      http_header_name = "X-Origin-Token"
      values           = [random_string.origin.result]
    }
  }
  condition {
    http_header {
      http_header_name = "Authentication"
      values           = [random_string.password.result]
    }

  }
}
#resource "aws_lb_listener" "https" {
#  load_balancer_arn = aws_lb.main.arn
#  port = 443
#  protocol = "HTTPS"
#  certificate_arn = ....
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.main.arn
#  }
#}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.service_name}-${var.env}-lb-logs"
  acl    = "private"

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.service_name}-${var.env}-lb-logs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
  tags   = merge(local.default_tags, {})
}

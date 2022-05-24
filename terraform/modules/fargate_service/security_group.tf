resource "aws_security_group" "service" {
  name        = "${var.service_name}-${var.env}"
  description = "allow web traffic"
  vpc_id      = data.aws_vpc.main.id

  #  ingress {
  #    from_port   = 80
  #    to_port     = 80
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
  #
  #  ingress {
  #    from_port   = 443
  #    to_port     = 443
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}
#data "aws_ip_ranges" "cloudfront" { # too many for security group
#services = ["cloudfront"]
#}
resource "aws_security_group" "lb" {
  name        = "${var.service_name}-${var.env}-lb"
  description = "allow web traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #cidr_blocks = data.aws_ip_ranges.cloudfront.cidr_blocks
  }

  #  ingress {
  #    from_port   = 443
  #    to_port     = 443
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}
resource "aws_security_group" "efs" {
  name        = "${var.service_name}-${var.env}-efs"
  description = "allow app traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.service.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}

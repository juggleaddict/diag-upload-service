resource "aws_iam_role" "ecs_task" {
  name               = "${var.service_name}-${var.env}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_trust_relationship.json
  tags               = local.default_tags
}

data "aws_iam_policy_document" "ecs_trust_relationship" {
  statement {
    sid     = "AllowECS"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    sid = "kmsForSSM"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "ssm"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "efs"
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount"
    ]
    resources = [
      "${aws_efs_file_system.main.arn}"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task" {
  name   = "${var.service_name}-${var.env}-ecs-task"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task.json
}

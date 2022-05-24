resource "aws_efs_file_system" "main" {
  creation_token = "${var.service_name}-${var.env}"
  tags           = merge(local.default_tags, {})
}

resource "aws_efs_mount_target" "main" {
  for_each        = var.private_subnets
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.private[each.key].id
  security_groups = [aws_security_group.efs.id]
}

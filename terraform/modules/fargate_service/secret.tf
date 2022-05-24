resource "random_string" "password" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "auth" {
  name = "${var.service_name}-${var.env}-password"
}

resource "aws_secretsmanager_secret_version" "auth_pw" {
  secret_id     = aws_secretsmanager_secret.auth.id
  secret_string = random_string.password.result
}

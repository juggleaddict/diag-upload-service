variable "service_name" {
}
variable "env" {
}
locals {
  default_tags = {
    env     = var.env
    service = var.service_name
  }
}
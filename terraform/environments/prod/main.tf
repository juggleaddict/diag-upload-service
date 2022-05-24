locals {
  service_name = "diag-upload-service"
  env          = "prod"
}

provider "aws" {
  region = "us-east-2"
}
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

module "service" {
  source = "../../modules/fargate_service"

  service_name = local.service_name
  env          = local.env
  image        = "billcchung/diag-upload-service:main"
  app_port     = 8000
  vpc_name     = "main"
  waf_arn      = module.waf.waf_arn
}

module "waf" {
  source = "../../modules/waf"
  providers = {
    aws = aws.us-east-1
  }
  service_name = local.service_name
  env          = local.env
}

terraform {

  backend "s3" {
    bucket = "514815999544-tfstate"
    key    = "states/diag-upload-service/prod/terraform.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.28.0"
    }
  }

  required_version = ">= 1.1.0"
}
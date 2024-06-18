terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.36"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
  profile = var.iam_profile.source_profile

  assume_role {
    role_arn = var.iam_profile.role_arn
  }
}

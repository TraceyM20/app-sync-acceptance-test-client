terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

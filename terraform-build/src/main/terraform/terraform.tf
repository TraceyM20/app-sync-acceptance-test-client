terraform {
  required_version = "1.0.0"

  // Setup backend for terraform, do not change it if you do know what it is.
  backend "s3" {
    encrypt        = true
    bucket         = "vts-nep-build-terraform-remote-state"
    dynamodb_table = "vts-nep-build-terraform-remote-state"
    region         = "ap-southeast-2"
    key            = "vts-nep/new-project-template/pipeline/build/terraform.tfstate"
    role_arn       = "arn:aws:iam::794701946555:role/vts-nep-build-ca-support"
    profile        = "Benched-Metering-Support-VMAU"
  }
}

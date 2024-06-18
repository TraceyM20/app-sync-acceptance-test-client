terraform {
  required_version = "1.0.0"

  // Setup backend for terraform, do not change it if you do know what it is.
  backend "s3" {
    encrypt        = true
    bucket         = "vts-nep-dev-terraform-remote-state"
    dynamodb_table = "vts-nep-dev-terraform-remote-state"
    region         = "ap-southeast-2"
    key            = "vts-nep/new-project-template/pipeline/build/terraform.tfstate"
    // We need to eventually run without a profile (i.e. from codebuild/pipeline) and with specific terraform roles
    role_arn       = "arn:aws:iam::794701946555:role/vts-nep-sandbox-ca-support"
    profile        = "VTS-NEP-Development"
  }
}

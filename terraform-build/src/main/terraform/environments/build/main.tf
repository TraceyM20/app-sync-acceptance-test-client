locals {
  service_name   = "vts-nep"
  component_name = "new-project-template"
  environment    = "build"
}

module "main" {
  source = "../.."

  service_name                        = local.service_name
  component_name                      = local.component_name
  environment                         = local.environment
  git_project_name                    = "nep-new-project-template"
  environment_remote_state_bucket_arn = "arn:aws:s3:::vts-nep-build-terraform-remote-state"
  environment_remote_state_table_arn  = "arn:aws:dynamodb:ap-southeast-2:794701946555:table/vts-nep-build-terraform-remote-state"
  management_kms_arn                  = "arn:aws:kms:ap-southeast-2:794701946555:key/5bd40817-f6e8-4eb2-8b78-6b6f7c4d5256"
  application_kms_arn                 = "arn:aws:kms:ap-southeast-2:794701946555:key/53dc1e3f-04da-489a-b5f4-01eb98e29fc8"
  release_bucket_arn                  = "arn:aws:s3:::vts-nep-build-release-artifacts"
  release_bucket_name                 = "vts-nep-build-release-artifacts"
  release_bucket_kms_key              = "arn:aws:kms:ap-southeast-2:794701946555:key/7a2fcde8-ed0d-4ed2-b4e4-87edcc87c706"
  pipeline_secret_kms_key             = "arn:aws:kms:ap-southeast-2:794701946555:key/5bd40817-f6e8-4eb2-8b78-6b6f7c4d5256"
  cost_group                          = "meteringau-nep"
  created_by                          = "terraform: manual"
  owner                               = "nep.operations@vector.co.nz"
  log_retention_days                  = 1
  iam_profile                         = {
    role_arn       = "arn:aws:iam::794701946555:role/vts-nep-build-ca-support"
    source_profile = "Benched-Metering-Support-VMAU"
    profile_name   = "nep-build-support"
  }

  acceptance_parameter_store_values = {
    "timezone/business"               = {
      value = "Pacific/Auckland"
      type  = "String"
    }
    "timezone/quantity"               = {
      value = "+12:00"
      type  = "String"
    }
    "timezone/system"                 = {
      value = "UTC"
      type  = "String"
    }
    "service/configuration-base-path" = {
      value = "/vts-nep-new-project-template/build/"
      type  = "String"
    }
    "http/security-protocol"          = {
      value = "TLSv1.2"
      type  = "String"
    }
    "service.base-url"                = {
      value = "https://api.build.nep.vts.nz/service/new-project-template"
      type  = "String"
    }
    "cognito.url"                     = {
      value = "https://api.build.nep.vts.nz/service/security"
      type  = "String"
    }
  }

  release_smoke_parameter_store_values = {
    "timezone/business" = {
      value = "Pacific/Auckland"
      type  = "String"
    }
    "timezone/quantity" = {
      value = "+12:00"
      type  = "String"
    }
    "timezone/system"   = {
      value = "UTC"
      type  = "String"
    }
  }

  application_parameter_store_values = {
    "timezone/business" = {
      value = "Pacific/Auckland"
      type  = "String"
    }
    "timezone/quantity" = {
      value = "+12:00"
      type  = "String"
    }
    "timezone/system"   = {
      value = "UTC"
      type  = "String"
    }
  }

  application_domain_name           = "new-project-template.origin.build.nep.vts.nz"
  application_hosted_zone_id        = "Z08108181SYN493YDAKGP"
  application_cognito_user_pool_id  = "ap-southeast-2_wly6HkIAG"
  application_cognito_user_pool_arn = "arn:aws:cognito-idp:ap-southeast-2:794701946555:userpool/ap-southeast-2_wly6HkIAG"
  application_web_acl_arn           = "arn:aws:wafv2:ap-southeast-2:794701946555:regional/webacl/vts-nep-temp-build-access-control/536f594e-f9ca-4347-8b83-696ad702d863"
}

variable "service_name" {
  type = string
}

variable "component_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "terraform_version" {
  type    = string
  default = "1.0.0"
}

variable "environment_remote_state_bucket_arn" {
  type = string
}

variable "environment_remote_state_table_arn" {
  type = string
}

variable "management_kms_arn" {
  type      = string
  sensitive = true
}

variable "application_kms_arn" {
  type      = string
  sensitive = true
}

variable "release_bucket_arn" {
  type = string
}

variable "release_bucket_name" {
  type = string
}

variable "release_bucket_kms_key" {
  type      = string
  sensitive = true
}

variable "pipeline_secret_kms_key" {
  type      = string
  sensitive = true
}

variable "git_organisation" {
  type    = string
  default = "vector-technology-services"
}

variable "git_project_name" {
  type = string
}

variable "git_branch" {
  type    = string
  default = "main"
}

variable "cost_group" {
  type = string
}

variable "created_by" {
  type = string
}

variable "owner" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "pipeline_secret_arn" {
  type    = string
  default = "arn:aws:secretsmanager:ap-southeast-2:794701946555:secret:vts-nep-pipeline-secrets-GPRHz6"
}

variable "maven_secrets" {
  type    = object({
    maven_settings_path = string
  })
  default = {
    maven_settings_path = "vts-nep-pipeline-secrets:MavenSettingsPath"
  }
}

variable "git_secrets" {
  type    = object({
    user_name  = string
    user_email = string
    account_id = string
  })
  default = {
    user_name  = "vts-nep-pipeline-secrets:GitUserName"
    user_email = "vts-nep-pipeline-secrets:GitUserEmail"
    account_id = "vts-nep-pipeline-secrets:GitAccountId"
  }
}

variable "git_secrets_keys" {
  type    = object({
    account_id = string
  })
  default = {
    account_id = "GitAccountId"
  }
}

variable "jfrog_secrets" {
  type    = object({
    release_repo        = string
    snapshot_repo       = string
    release_local_repo  = string
    snapshot_local_repo = string
    username            = string
    token               = string
  })
  default = {
    release_repo        = "vts-nep-pipeline-secrets:JfrogReleaseRepo"
    snapshot_repo       = "vts-nep-pipeline-secrets:JfrogSnapshotRepo"
    release_local_repo  = "vts-nep-pipeline-secrets:JfrogReleaseLocalRepo"
    snapshot_local_repo = "vts-nep-pipeline-secrets:JfrogSnapshotLocalRepo"
    username            = "vts-nep-pipeline-secrets:JfrogUsername"
    token               = "vts-nep-pipeline-secrets:JfrogToken"
  }
}

variable "sonarcloud_secrets" {
  type    = object({
    sonarcloud_scanner_zip_path = string
    sonarcloud_settings_path    = string
    sonarcloud_endpoint         = string
    sonarcloud_organisation     = string
    sonarcloud_token            = string
  })
  default = {
    sonarcloud_scanner_zip_path = "vts-nep-pipeline-secrets:SonarCloudScannerZipPath"
    sonarcloud_settings_path    = "vts-nep-pipeline-secrets:SonarCloudSettingsPath"
    sonarcloud_endpoint         = "vts-nep-pipeline-secrets:SonarCloudEndpoint"
    sonarcloud_organisation     = "vts-nep-pipeline-secrets:SonarCloudOrganisation"
    sonarcloud_token            = "vts-nep-pipeline-secrets:SonarCloudToken"
  }
}

variable "iam_profile" {
  type = object({
    role_arn       = string
    source_profile = string
    profile_name   = string
  })
}

variable "acceptance_parameter_store_values" {
  type = map(object({
    value = string
    type  = string
  }))
}

// The following are required to configure terraform-release

variable "release_smoke_parameter_store_values" {
  type = map(object({
    value = string
    type  = string
  }))
}

// The following are required to configure terraform-application

variable "application_parameter_store_values" {
  type = map(object({
    value = string
    type  = string
  }))
}

variable "application_domain_name" {
  type = string
}

variable "application_hosted_zone_id" {
  type = string
}

variable "application_cognito_user_pool_id" {
  type = string
}

variable "application_cognito_user_pool_arn" {
  type = string
}

variable "application_web_acl_arn" {
  type = string
}

variable "vpc_id_ssm_path" {
  type    = string
  default = null
}

variable "vpc_private_subnet_ssm_path" {
  type    = string
  default = null
}

variable "vpc_public_subnet_ssm_path" {
  type    = string
  default = null
}

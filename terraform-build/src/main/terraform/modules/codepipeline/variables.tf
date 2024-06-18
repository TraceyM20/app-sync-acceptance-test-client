variable "name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "source_object_key" {
  type = string
}

variable "kms_key" {
  type      = string
  sensitive = true
}

variable "release_bucket_name" {
  type = string
}

variable "release_bucket_kms_key" {
  type      = string
  sensitive = true
}

variable "iam_role" {
  type = string
}

variable "profile_name" {
  type = string
}

variable "maven_build_codebuild" {
  type = string
}

variable "code_quality_codebuild" {
  type = string
}

variable "deploy_release_pipeline_codebuild" {
  type = string
}

variable "bundle_release_pipeline_config_codebuild" {
  type = string
}

variable "trigger_release_pipeline_codebuild" {
  type = string
}

variable "maven_release_codebuild" {
  type = string
}

variable "deploy_acceptance_codebuild" {
  type = string
}

variable "acceptance_codebuild" {
  type = string
}

variable "tags" {
  type = object({
    costgroup   = string
    env         = string
    application = string
    created-by  = string
    owner       = string
  })
}

variable "name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "object_key" {
  type = string
}

variable "kms_key" {
  type      = string
  sensitive = true
}

variable "iam_role" {
  type = string
}

variable "deploy_infrastructure_codebuild" {
  type = string
}

variable "deploy_lambda_codebuilds" {
  type = map(object({
    codebuild_name      = string
    lambda_arn_variable = string
  }))
}

variable "deploy_api_gateway_codebuild" {
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

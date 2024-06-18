variable "service_name" {
  type = string
}

variable "component_name" {
  type = string
}

variable "environment" {
  type = string
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

variable "config_s3_name" {
  type = string
}

variable "application_config_path" {
  type = string
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

variable "number_of_api_deployments_to_keep" {
  type    = number
  default = 3

  validation {
    condition     = var.number_of_api_deployments_to_keep > 0
    error_message = "Invalid number of api deployments to keep."
  }
}

variable "log_retention_days" {
  type = number
}

variable "number_of_lambda_versions_to_keep" {
  type    = number
  default = 3

  validation {
    condition     = var.number_of_lambda_versions_to_keep > 0
    error_message = "Invalid number of lambda versions to keep."
  }
}

variable "max_deployment_attempts" {
  type    = number
  default = 10
}

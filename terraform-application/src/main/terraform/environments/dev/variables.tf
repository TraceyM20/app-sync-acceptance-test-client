variable "service_name" {
  type = string
}

variable "component_name" {
  type = string
}

variable "environment" {
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

variable "application_kms_arn" {
  type      = string
  sensitive = true
}

variable "log_retention_days" {
  type = number
}

variable "log_level" {
  type = string
}

variable "parameter_store_values" {
  type = map(object({
    value = string
    type  = string
  }))
}

variable "wiremock_configuration" {
  type = object({
    vpc_id = string
    subnet_ids = list(string)
  })
}

variable "domain_name" {
  type = string

  validation {
    condition     = can(regex("^(([A-Za-z0-9-]{0,62}[A-Za-z0-9])\\.)+([A-Za-z0-9-]{0,62}[A-Za-z0-9])$", var.domain_name))
    error_message = "Invalid Domain Name."
  }
}

variable "hosted_zone_id" {
  type = string
}

variable "cognito_user_pool_arn" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "web_acl_arn" {
  type = string
}

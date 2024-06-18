variable "service_name" {
  type = string
}

variable "component_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "management_kms_arn" {
  type      = string
  sensitive = true
}

variable "application_state_config" {
  type = object({
    backend = string
    config  = object({
      encrypt        = string
      bucket         = string
      dynamodb_table = string
      region         = string
      key            = string
    })
  })
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

variable "parameter_store_values" {
  type = map(object({
    value = string
    type  = string
  }))
}

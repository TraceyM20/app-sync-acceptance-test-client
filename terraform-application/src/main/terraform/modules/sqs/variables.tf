variable "name" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "kms_key" {
  type      = string
  sensitive = true
}

variable "polling_function_timeout" {
  type = number
}

variable "tags" {
  type = object({
    costgroup  = string
    env        = string
    owner      = string
    created-by = string
  })
}

variable "max_retry_attempt" {
  type    = number
  default = 5
}

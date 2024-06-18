variable "name" {
  type = string
}

variable "alias_name" {
  type = string
}

variable "runtime" {
  type    = string
  default = "java11"
}

variable "memory" {
  type    = number
  default = 512
}

variable "timeout" {
  type    = number
  default = 30
}

variable "handler" {
  type = string
}

variable "environment_variables" {
  type = map(string)
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  type    = map(string)
  default = {}
}

variable "log_retention_days" {
  type = number
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

variable "vpc_configuration" {
  type    = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

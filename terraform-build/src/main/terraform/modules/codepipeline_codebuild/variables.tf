variable "name" {
  type = string
}

variable "buildspec" {
  type = string
}

variable "build_timeout" {
  type    = number
  default = 30
}

variable "compute_type" {
  type    = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  type    = string
  default = "aws/codebuild/standard:5.0"
}

variable "container_type" {
  type    = string
  default = "LINUX_CONTAINER"
}

variable "cache_location" {
  type    = string
  default = ""
}

variable "kms_key" {
  type      = string
  sensitive = true
}

variable "iam_role" {
  type = string
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

variable "vpc_config" {
  type = object({
    subnets = list(string)
    vpc_id = string
    security_group_id = string
  })
  default = null
}

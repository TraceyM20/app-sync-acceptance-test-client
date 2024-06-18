variable "name" {
  type = string
}

variable "api_id" {
  type = string
}

variable "log_group_arn" {
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

variable "web_acl_arn" {
  type = string
}

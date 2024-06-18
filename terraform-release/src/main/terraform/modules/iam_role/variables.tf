variable "name" {
  type = string
}

variable "assume_role_policy" {
  type = string
}

variable "can_assume_self" {
  type    = bool
  default = false
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  type    = map(string)
  default = {}
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

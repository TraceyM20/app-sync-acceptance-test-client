variable "api_id" {
  type = string
}

variable "parent_resource_id" {
  type = string
}

variable "path" {
  type = string
}

variable "methods" {
  type    = map(object({
    cognito_scopes = list(string)
  }))
  default = {}
}

variable "authorizer_id" {
  type    = string
  default = null
}

variable "api_id" {
  type = string
}

variable "parent_resource_id" {
  type = string
}

variable "authorizer_id" {
  type    = string
  default = null
}

variable "cognito_scopes" {
  type = list(string)
}

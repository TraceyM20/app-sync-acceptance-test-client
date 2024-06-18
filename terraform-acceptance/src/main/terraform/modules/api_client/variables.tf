variable "name" {
  type = string
}

variable "api_gateway_usage_plan_id" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "oauth_flows" {
  type    = list(string)
  default = ["client_credentials"]
}

variable "user_authentication_scopes" {
  type = list(string)
}

variable "callback_urls" {
  type    = list(string)
  default = ["https://localhost"]
}

variable "auth_flows" {
  type    = list(string)
  default = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

variable "refresh_token_valid_days" {
  type    = number
  default = 7
}

variable "identity_providers" {
  type    = list(string)
  default = ["COGNITO"]
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

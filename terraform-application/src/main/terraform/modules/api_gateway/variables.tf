variable "name" {
  type = string
}

variable "api_endpoint_configuration" {
  type    = string
  default = "REGIONAL"
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

variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "cognito_user_pool_arn" {
  type = string
}

variable "cognito_scopes" {
  type = map(string)
}

variable "web_acl_arn" {
  type = string
}

variable "lambda_integrations" {
  type = map(object({
    lambda_arn        = string
    lambda_invoke_arn = string
    cognito_scopes    = list(string)
  }))
}

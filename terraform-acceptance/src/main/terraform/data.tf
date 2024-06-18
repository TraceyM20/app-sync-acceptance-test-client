locals {
  application_api_gateway_usage_plan_id              = data.terraform_remote_state.application.outputs.api_gateway_usage_plan
  application_cognito_user_pool_id                   = data.terraform_remote_state.application.outputs.cognito_user_pool_id
  application_cognito_authentication_scopes          = data.terraform_remote_state.application.outputs.cognito_authentication_scopes
}

data "terraform_remote_state" "application" {
  backend = var.application_state_config.backend
  config  = var.application_state_config.config
}

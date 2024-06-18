resource "aws_api_gateway_api_key" "this" {
  name = var.name

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_api_gateway_usage_plan_key" "this" {
  usage_plan_id = var.api_gateway_usage_plan_id
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = var.name
  user_pool_id                         = var.cognito_user_pool_id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = var.oauth_flows
  allowed_oauth_scopes                 = var.user_authentication_scopes
  callback_urls                        = var.callback_urls
  explicit_auth_flows                  = var.auth_flows
  enable_token_revocation              = true
  generate_secret                      = true
  prevent_user_existence_errors        = "ENABLED"
  refresh_token_validity               = var.refresh_token_valid_days
  supported_identity_providers         = var.identity_providers
}

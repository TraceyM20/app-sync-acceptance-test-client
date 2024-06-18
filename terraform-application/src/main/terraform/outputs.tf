output "hello_lambda_arn" {
  value = module.hello_lambda.lambda_arn
}

output "hello_lambda_alias_arn" {
  value = module.hello_lambda.alias_arn
}

output "base_api_gateway_id" {
  value = module.base_api_gateway.api_id
}

output "base_api_gateway_stage_name" {
  value = module.base_api_gateway.api_stage_name
}

output "base_api_gateway_root_resource_id" {
  value = module.base_api_gateway.root_resource_id
}

output "api_gateway_usage_plan" {
  value = module.base_api_gateway.api_usage_plan
}

output "cognito_user_pool_id" {
  value = var.cognito_user_pool_id
}

output "cognito_authentication_scopes" {
  value = values(module.cognito.scope_identifiers)
}

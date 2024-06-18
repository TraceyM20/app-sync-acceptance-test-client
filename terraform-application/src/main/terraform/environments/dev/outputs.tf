output "hello_lambda_arn" {
  value = module.main.hello_lambda_arn
}

output "hello_lambda_alias_arn" {
  value = module.main.hello_lambda_alias_arn
}

output "root_api_gateway_id" {
  value = module.main.base_api_gateway_id
}

output "root_api_gateway_stage_name" {
  value = module.main.base_api_gateway_stage_name
}

output "root_api_gateway_root_resource_id" {
  value = module.main.base_api_gateway_root_resource_id
}

output "api_gateway_usage_plan" {
  value = module.main.api_gateway_usage_plan
}

output "cognito_user_pool_id" {
  value = var.cognito_user_pool_id
}

output "cognito_authentication_scopes" {
  value = module.main.cognito_authentication_scopes
}

output "api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  value = aws_api_gateway_rest_api.this.arn
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

output "api_stage_name" {
  value = module.api_gateway_stage.stage_name
}

output "api_stage_arn" {
  value = module.api_gateway_stage.stage_arn
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.access.arn
}

output "api_usage_plan" {
  value = aws_api_gateway_usage_plan.this.id
}

output "authorizer_id" {
  value = aws_api_gateway_authorizer.this.id
}

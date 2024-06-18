locals {
  stage_name = "${var.name}-environment"

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_api_gateway_rest_api" "this" {
  name               = var.name
  binary_media_types = ["application/gzip"]

  endpoint_configuration {
    types = [var.api_endpoint_configuration]
  }

  tags = local.tags
}

module "api_gateway_custom_domain" {
  source     = "./custom_domain"
  depends_on = [module.api_gateway_stage]

  name           = var.name
  api_id         = aws_api_gateway_rest_api.this.id
  api_stage_name = module.api_gateway_stage.stage_name
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id

  tags = local.tags
}

resource "aws_api_gateway_authorizer" "this" {
  name            = "${var.name}-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.this.id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [var.cognito_user_pool_arn]
}

module "api_gateway_responses" {
  source = "./gateway_responses"

  api_id = aws_api_gateway_rest_api.this.id
}

module "api_gateway_health" {
  source = "./health_endpoint"

  api_id             = aws_api_gateway_rest_api.this.id
  parent_resource_id = aws_api_gateway_rest_api.this.root_resource_id
  authorizer_id      = aws_api_gateway_authorizer.this.id
  cognito_scopes = [for k, v in var.cognito_scopes : v if k != "none"]
}

module "api_gateway_service" {
  source = "./service/hello"

  api_id             = aws_api_gateway_rest_api.this.id
  parent_resource_id = aws_api_gateway_rest_api.this.root_resource_id
  authorizer_id      = aws_api_gateway_authorizer.this.id
  lambda_integrations = var.lambda_integrations
  stage_name = local.stage_name
}

module "api_gateway_stage" {
  source     = "./stage"
  depends_on = [module.api_gateway_health]

  name          = local.stage_name
  api_id        = aws_api_gateway_rest_api.this.id
  log_group_arn = aws_cloudwatch_log_group.access.arn
  web_acl_arn   = var.web_acl_arn

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "access" {
  name              = "API-Gateway-Access-Logs_${aws_api_gateway_rest_api.this.id}/${var.name}-environment"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-access-logs"
  })
}

// This is overwriting the default execution log group created by API Gateway - so that it can be cleaned up
resource "aws_cloudwatch_log_group" "execution" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/${var.name}-environment"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-execution-logs"
  })
}

resource "aws_api_gateway_usage_plan" "this" {
  name = var.name

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = module.api_gateway_stage.stage_name
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

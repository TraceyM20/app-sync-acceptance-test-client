locals {
  prefix              = "${var.service_name}-${var.component_name}-${var.environment}-acceptance"
  root_parameter_path = "/${var.service_name}-${var.component_name}/${var.environment}-acceptance"

  parameter_store_values = merge(var.parameter_store_values, {
    "authorised-api-key"       = {
      value = module.authorised_api_client.api_key
      type  = "SecureString"
    }
    "authorised-client-id"     = {
      value = module.authorised_api_client.client_id
      type  = "SecureString"
    }
    "authorised-client-secret" = {
      value = module.authorised_api_client.client_secret
      type  = "SecureString"
    }
  })

  tags = {
    costgroup   = var.cost_group
    env         = var.environment
    application = "${var.service_name}-${var.component_name}"
    created-by  = var.created_by
    owner       = var.owner
  }
}

module "authorised_api_client" {
  source = "./modules/api_client"

  name                       = "${local.prefix}-app-client"
  api_gateway_usage_plan_id  = local.application_api_gateway_usage_plan_id
  cognito_user_pool_id       = local.application_cognito_user_pool_id
  user_authentication_scopes = local.application_cognito_authentication_scopes

  tags = local.tags
}

module "root_parameter" {
  source = "./fragments/ssm_parameter"

  name    = "${local.prefix}-root"
  path    = local.root_parameter_path
  value   = local.prefix
  kms_key = var.management_kms_arn

  tags = local.tags
}

module "parameter_store_values" {
  source = "./fragments/ssm_parameter"

  for_each = local.parameter_store_values

  name    = "${local.prefix}-${each.key}"
  path    = "${local.root_parameter_path}/${each.key}"
  value   = each.value["value"]
  type    = each.value["type"]
  kms_key = var.management_kms_arn

  tags = local.tags
}

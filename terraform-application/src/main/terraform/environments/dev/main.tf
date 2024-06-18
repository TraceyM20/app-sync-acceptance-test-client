module "main" {
  source = "../.."

  service_name            = var.service_name
  component_name          = var.component_name
  environment             = var.environment
  application_kms_arn     = var.application_kms_arn
  owner                   = var.owner
  cost_group              = var.cost_group
  log_retention_days      = var.log_retention_days
  log_level               = var.log_level
  parameter_store_values  = var.parameter_store_values

  cognito_user_pool_id      = var.cognito_user_pool_id
  cognito_user_pool_arn     = var.cognito_user_pool_arn
  hosted_zone_id            = var.hosted_zone_id
  domain_name               = var.domain_name
  vpc_configuration         = var.wiremock_configuration
  web_acl_arn               = var.web_acl_arn
}

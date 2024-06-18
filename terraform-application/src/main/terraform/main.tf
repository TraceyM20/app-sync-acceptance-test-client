locals {
  prefix              = "${var.service_name}-${var.component_name}-${var.environment}"
  root_parameter_path = "/${var.service_name}-${var.component_name}/${var.environment}"
  action_target       = "action-target"

  created_by = "https://github.com/vector-technology-services/nep-new-project-template"

  partition_key              = "Id"
  sort_key                   = "CreatedDateTime"
  queue_name                 = "queue"
  topic_name                 = "topic"
  message_processing_timeout = 30
  sqs_max_retry_attempt      = 5

  tags = {
    costgroup   = var.cost_group
    env         = var.environment
    application = "${var.service_name}-${var.component_name}"
    created-by  = local.created_by
    owner       = var.owner
  }

  cognito_scopes = {
    "new-project-template-scope" = "Create and update data services"
    "none"                       = "No access for testing"
  }

  lambda_integrations = {
    hello = {
      lambda_arn        = module.hello_lambda.lambda_arn
      lambda_invoke_arn = module.hello_lambda.alias_invoke_arn
      cognito_scopes    = [module.cognito.scope_identifiers["new-project-template-scope"]]
    }
  }
}

module "base_api_gateway" {
  source = "./modules/api_gateway"

  name                  = local.prefix
  domain_name           = var.domain_name
  hosted_zone_id        = var.hosted_zone_id
  web_acl_arn           = var.web_acl_arn
  log_retention_days    = var.log_retention_days
  cognito_user_pool_arn = var.cognito_user_pool_arn
  cognito_scopes        = module.cognito.scope_identifiers
  lambda_integrations   = local.lambda_integrations
  tags                  = local.tags
}

module "hello_lambda" {
  source = "./modules/lambda"

  name                = "${local.prefix}-hello-api-lambda"
  handler             = "nz.vts.nep.template.hello.HelloHandler::handleRequest"
  managed_policy_arns = []
  inline_policies     = {
    "ssm-policy" = module.ssm_policy.policy_document_json
  }
  environment_variables = {
    "AWS_ENVIRONMENT"             = "TRUE"
    "LOG_LEVEL"                   = var.log_level
    "CONFIGURATION_SSM_BASE_PATH" = "${local.root_parameter_path}/"
  }
  log_retention_days = var.log_retention_days
  alias_name         = local.action_target
  vpc_configuration  = var.vpc_configuration != null ? {
    subnet_ids         = var.vpc_configuration.subnet_ids,
    security_group_ids = [module.vpc_security_group[0].security_group_id]
  } : null

  tags = local.tags
}

module "cognito" {
  source = "./modules/cognito"

  name         = "${local.prefix}-rest-endpoint"
  identifier   = local.prefix
  user_pool_id = var.cognito_user_pool_id
  scopes       = local.cognito_scopes
}

module "root_parameter" {
  source = "./fragments/ssm_parameter"

  name    = "${local.prefix}-root"
  path    = local.root_parameter_path
  value   = local.prefix
  kms_key = var.application_kms_arn

  tags = local.tags
}

module "environment_parameter_store_values" {
  source = "./fragments/ssm_parameter"

  for_each = var.parameter_store_values

  name    = "${local.prefix}-${each.key}"
  path    = "${local.root_parameter_path}/${each.key}"
  value   = each.value["value"]
  type    = each.value["type"]
  kms_key = var.application_kms_arn

  tags = local.tags
}

module "vpc_security_group" {
  source = "./modules/vpc_security_group"

  count = var.vpc_configuration != null ? 1 : 0

  name   = "${local.prefix}-vpc-security-group"
  vpc_id = var.vpc_configuration.vpc_id

  tags = local.tags
}

module "hello_dynamodb" {
  source = "./modules/dynamo_db"

  name           = "${local.prefix}-dynamo-table"
  partition_key  = local.partition_key
  sort_key       = local.sort_key
  kms_key        = var.application_kms_arn
  attribute_list = [
    {
      key_name = local.partition_key,
      key_type = "S"
    },
    {
      key_name = local.sort_key,
      key_type = "S"
    }
  ]

  tags = local.tags
}

module "hello_sns" {
  source = "./modules/sns"

  topic_name = "${local.prefix}-${local.topic_name}"
}

module "hello_queue" {
  source = "./modules/sqs"

  name                     = "${local.prefix}-${local.queue_name}"
  kms_key                  = var.application_kms_arn
  polling_function_timeout = local.message_processing_timeout
  max_retry_attempt        = local.sqs_max_retry_attempt
  sns_topic_arn            = module.hello_sns.sns_arn

  tags = local.tags
}

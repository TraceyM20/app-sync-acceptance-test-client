locals {
  prefix              = "${var.service_name}-${var.component_name}-${var.environment}"
  release_prefix      = "${local.prefix}-release"
  root_parameter_path = "/${var.service_name}-${var.component_name}/${var.environment}"

  tags = {
    costgroup   = var.cost_group
    env         = var.environment
    application = "${var.service_name}-${var.component_name}"
    created-by  = var.created_by
    owner       = var.owner
  }
}

module "release_pipeline" {
  source = "./modules/codepipeline"

  name                            = local.release_prefix
  bucket_name                     = var.config_s3_name
  object_key                      = var.application_config_path
  kms_key                         = var.management_kms_arn
  iam_role                        = module.pipeline_role.role_arn
  deploy_infrastructure_codebuild = module.deploy_infrastructure_codebuild.codebuild_name
  deploy_lambda_codebuilds = {
    DeployHelloLambda = {
      codebuild_name      = module.deploy_hello_lambda_codebuild.codebuild_name
      lambda_arn_variable = "HELLO_LAMBDA_ARN"
    }
  }

  deploy_api_gateway_codebuild    = module.deploy_api_gateway_codebuild.codebuild_name
  tags = local.tags
}

module "deploy_infrastructure_codebuild" {
  source = "./modules/codebuild"

  name               = "${local.release_prefix}-infrastructure"
  buildspec          = templatefile("${path.module}/buildspecs/deploy_infrastructure.yml", {})
  iam_role           = module.deploy_infrastructure_role.role_arn
  kms_key            = var.management_kms_arn
  // Certificate validation can take up to 30 minutes
  build_timeout      = 60
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "deploy_hello_lambda_codebuild" {
  source = "./modules/codebuild"

  name               = "${local.release_prefix}-hello-api-lambda"
  buildspec          = templatefile("${path.module}/buildspecs/deploy_lambda.yml", {
    source_name                = "hello-api-lambda"
    number_of_versions_to_keep = var.number_of_lambda_versions_to_keep
    max_deployment_attempts    = var.max_deployment_attempts
  })
  iam_role           = module.deploy_application_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "deploy_api_gateway_codebuild" {
  source = "./modules/codebuild"

  name               = "${local.release_prefix}-api-gateway"
  buildspec          = templatefile("${path.module}/buildspecs/deploy_api_gateway.yml", {
    component_name                    = var.component_name
    number_of_api_deployments_to_keep = var.number_of_api_deployments_to_keep
    max_deployment_attempts    = var.max_deployment_attempts
  })
  iam_role           = module.deploy_application_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

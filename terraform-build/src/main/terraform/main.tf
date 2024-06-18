locals {
  prefix                         = "${var.service_name}-${var.component_name}-${var.environment}"
  build_prefix                   = "${local.prefix}-build"
  root_parameter_path            = "/${var.service_name}-${var.component_name}/${var.environment}"
  acceptance_root_parameter_path = "${local.root_parameter_path}-acceptance"
  pipeline_source_object_key     = "git-source.zip"
  maven_cache_location           = "${module.pipeline_bucket.bucket_name}/cache/maven"
  sonar_cache_location           = "${module.pipeline_bucket.bucket_name}/cache/sonar"
  release_pipeline_source_path   = "release/${var.component_name}/${var.component_name}-application-bundle.zip"
  config_indent                  = 10

  tags = {
    costgroup   = var.cost_group
    env         = var.environment
    application = "${var.service_name}-${var.component_name}"
    created-by  = var.created_by
    owner       = var.owner
  }
}

module "pipeline_bucket" {
  source = "./modules/s3"

  name       = "${local.build_prefix}-pipeline"
  kms_key    = var.management_kms_arn
  versioning = true

  tags = local.tags
}

module "build_pipeline" {
  source = "./modules/codepipeline"

  name                                     = local.build_prefix
  bucket_name                              = module.pipeline_bucket.bucket_name
  bucket_arn                               = module.pipeline_bucket.bucket_arn
  source_object_key                        = local.pipeline_source_object_key
  kms_key                                  = var.management_kms_arn
  release_bucket_name                      = var.release_bucket_name
  release_bucket_kms_key                   = var.release_bucket_kms_key
  iam_role                                 = module.pipeline_role.role_arn
  profile_name                             = var.iam_profile.profile_name
  maven_build_codebuild                    = module.maven_build_codebuild.codebuild_name
  code_quality_codebuild                   = module.code_quality_codebuild.codebuild_name
  deploy_release_pipeline_codebuild        = module.deploy_release_pipeline_codebuild.codebuild_name
  bundle_release_pipeline_config_codebuild = module.bundle_release_pipeline_config_codebuild.codebuild_name
  trigger_release_pipeline_codebuild       = module.trigger_release_pipeline_codebuild.codebuild_name
  maven_release_codebuild                  = module.maven_release_codebuild.codebuild_name
  deploy_acceptance_codebuild              = module.deploy_acceptance_codebuild.codebuild_name
  acceptance_codebuild                     = module.acceptance_codebuild.codebuild_name

  tags = local.tags
}

module "git_source_codebuild" {
  source = "./modules/git_source_codebuild"

  name               = "${local.build_prefix}-git-source"
  buildspec          = templatefile("${path.module}/buildspecs/git_source.yml", {})
  git_url            = "https://github.com/${var.git_organisation}/${var.git_project_name}.git"
  git_account_id     = local.pipeline_secrets[var.git_secrets_keys.account_id]
  git_branch         = var.git_branch
  output_bucket_name = module.pipeline_bucket.bucket_name
  output_bucket_key  = local.pipeline_source_object_key
  iam_role           = module.source_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "maven_build_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-maven-build-codebuild"
  buildspec          = templatefile("${path.module}/buildspecs/maven_build.yml", {
    component_name                   = var.component_name
    maven_settings_path              = var.maven_secrets.maven_settings_path
    jfrog_secret_release_repo        = var.jfrog_secrets.release_repo
    jfrog_secret_snapshot_repo       = var.jfrog_secrets.snapshot_repo
    jfrog_secret_release_local_repo  = var.jfrog_secrets.release_local_repo
    jfrog_secret_snapshot_local_repo = var.jfrog_secrets.snapshot_local_repo
    jfrog_secret_username            = var.jfrog_secrets.username
    jfrog_secret_token               = var.jfrog_secrets.token
  })
  cache_location     = local.maven_cache_location
  iam_role           = module.build_role.role_arn
  kms_key            = var.management_kms_arn
  build_timeout      = 60
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "code_quality_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-code-quality"
  image              = "aws/codebuild/standard:7.0"
  buildspec          = templatefile("${path.module}/buildspecs/code_quality.yml", {
    git_project_name                           = var.git_project_name
    sonarcloud_secret_sonarcloud_scanner_zip   = var.sonarcloud_secrets.sonarcloud_scanner_zip_path
    sonarcloud_secret_sonarcloud_settings_path = var.sonarcloud_secrets.sonarcloud_settings_path
    sonarcloud_secret_sonarcloud_endpoint      = var.sonarcloud_secrets.sonarcloud_endpoint
    sonarcloud_secret_sonarcloud_organisation  = var.sonarcloud_secrets.sonarcloud_organisation
    sonarcloud_secret_sonarcloud_token         = var.sonarcloud_secrets.sonarcloud_token
  })
  cache_location     = local.sonar_cache_location
  iam_role           = module.quality_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "deploy_release_pipeline_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-deploy-release-pipeline"
  buildspec          = templatefile("${path.module}/buildspecs/deploy_release_pipeline.yml", {
    terraform_tf        = indent(local.config_indent, templatefile("${path.module}/config/release/terraform.tf", {
      terraform_version = var.terraform_version
      service_name      = var.service_name
      component_name    = var.component_name
      environment       = var.environment
    }))
    terraform_tfvars    = indent(local.config_indent, templatefile("${path.module}/config/release/terraform.tfvars", {
      service_name                        = var.service_name
      component_name                      = var.component_name
      environment                         = var.environment
      environment_remote_state_bucket_arn = var.environment_remote_state_bucket_arn
      environment_remote_state_table_arn  = var.environment_remote_state_table_arn
      management_kms_arn                  = var.management_kms_arn
      application_kms_arn                 = var.application_kms_arn
      config_s3_name                      = module.pipeline_bucket.bucket_name
      application_config_path             = local.release_pipeline_source_path
      cost_group                          = var.cost_group
      owner                               = var.owner
      log_retention_days                  = var.log_retention_days
      smoke_parameter_store_values        = jsonencode(var.release_smoke_parameter_store_values)
    }))
    terraform_version   = var.terraform_version
    release_bucket_name = var.release_bucket_name
  })
  iam_role           = module.deploy_release_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "bundle_release_pipeline_config_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-bundle-release-pipeline-config"
  buildspec          = templatefile("${path.module}/buildspecs/bundle_release_pipeline_config.yml", {
    terraform_tf                 = indent(local.config_indent, templatefile("${path.module}/config/application/app_terraform.tf", {
      terraform_version = var.terraform_version
      service_name      = var.service_name
      component_name    = var.component_name
      environment       = var.environment
    }))
    release_properties_json      = indent(local.config_indent, templatefile("${path.module}/config/application/release-properties.json", {
      service_name       = var.service_name
      cost_group         = var.cost_group
      environment        = var.environment
      log_retention_days = var.log_retention_days
      component_name     = var.component_name
      terraform_version  = var.terraform_version
    }))
    config_json                  = indent(local.config_indent, templatefile("${path.module}/config/application/config.json", {
      service_name           = var.service_name
      component_name         = var.component_name
      environment            = var.environment
      application_kms_arn    = var.application_kms_arn
      domain_name            = var.application_domain_name
      hosted_zone_id         = var.application_hosted_zone_id
      web_acl_arn            = var.application_web_acl_arn
      cognito_user_pool_id   = var.application_cognito_user_pool_id
      cognito_user_pool_arn  = var.application_cognito_user_pool_arn
      cost_group             = var.cost_group
      owner                  = var.owner
      log_retention_days     = var.log_retention_days
      parameter_store_values = jsonencode(var.application_parameter_store_values)
      vpc_configuration      = jsonencode({
        subnet_ids = local.vpc_private_subnets_ids
        vpc_id  = local.vpc_id
      })
    }))
    terraform_version            = var.terraform_version
    release_bucket_name          = var.release_bucket_name
    release_pipeline_bucket_name = module.pipeline_bucket.bucket_name
    application_config_path      = local.release_pipeline_source_path
  })
  iam_role           = module.deploy_release_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "trigger_release_pipeline_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-trigger-release-pipeline"
  buildspec          = templatefile("${path.module}/buildspecs/trigger_release_pipeline.yml", {})
  iam_role           = module.deploy_release_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "deploy_acceptance_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-deploy-acceptance"
  buildspec          = templatefile("${path.module}/buildspecs/deploy_acceptance.yml", {
    terraform_tf        = indent(local.config_indent, templatefile("${path.module}/config/acceptance/terraform.tf", {
      terraform_version = var.terraform_version
      service_name      = var.service_name
      component_name    = var.component_name
      environment       = var.environment
    }))
    terraform_tfvars    = indent(local.config_indent, templatefile("${path.module}/config/acceptance/terraform.tfvars", {
      service_name             = var.service_name
      component_name           = var.component_name
      environment              = var.environment
      management_kms_arn       = var.management_kms_arn
      application_state_config = jsonencode({
        backend = "s3"
        config  = {
          encrypt        = true
          bucket         = "${var.service_name}-${var.environment}-terraform-remote-state"
          dynamodb_table = "${var.service_name}-${var.environment}-terraform-remote-state"
          region         = local.aws_region
          key            = "${var.service_name}/${var.component_name}/application/terraform.tfstate"
        }
      })
      cost_group               = var.cost_group
      owner                    = var.owner
      parameter_store_values   = jsonencode(var.acceptance_parameter_store_values)
    }))
    terraform_version   = var.terraform_version
    release_bucket_name = var.release_bucket_name
  })
  iam_role           = module.test_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "codebuild_vpc_security_group" {
  source = "./modules/vpc_security_group"

  name        = "${local.prefix}-acceptance-codebuild"
  description = "Acceptance Security Group"
  vpc_id      = local.vpc_id

  tags = local.tags
}

module "acceptance_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-acceptance"
  buildspec          = templatefile("${path.module}/buildspecs/acceptance.yml", {
    acceptance_module                = "acceptance"
    environment                      = var.environment
    role_arn                         = module.test_role.role_arn
    maven_settings_path              = var.maven_secrets.maven_settings_path
    jfrog_secret_release_repo        = var.jfrog_secrets.release_repo
    jfrog_secret_snapshot_repo       = var.jfrog_secrets.snapshot_repo
    jfrog_secret_release_local_repo  = var.jfrog_secrets.release_local_repo
    jfrog_secret_snapshot_local_repo = var.jfrog_secrets.snapshot_local_repo
    jfrog_secret_username            = var.jfrog_secrets.username
    jfrog_secret_token               = var.jfrog_secrets.token
  })
  vpc_config         = {
    subnets           = local.vpc_private_subnets_ids
    vpc_id            = local.vpc_id
    security_group_id = module.codebuild_vpc_security_group.security_group_id
  }
  cache_location     = local.maven_cache_location
  iam_role           = module.test_role.role_arn
  kms_key            = var.management_kms_arn
  build_timeout      = 90
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "maven_release_codebuild" {
  source = "./modules/codepipeline_codebuild"

  name               = "${local.build_prefix}-maven-release"
  buildspec          = templatefile("${path.module}/buildspecs/maven_release.yml", {
    application_name                 = var.component_name
    maven_settings_path              = var.maven_secrets.maven_settings_path
    jfrog_secret_release_repo        = var.jfrog_secrets.release_repo
    jfrog_secret_snapshot_repo       = var.jfrog_secrets.snapshot_repo
    jfrog_secret_release_local_repo  = var.jfrog_secrets.release_local_repo
    jfrog_secret_snapshot_local_repo = var.jfrog_secrets.snapshot_local_repo
    jfrog_secret_username            = var.jfrog_secrets.username
    jfrog_secret_token               = var.jfrog_secrets.token
    git_user_name                    = var.git_secrets.user_name
    git_user_email                   = var.git_secrets.user_email
  })
  cache_location     = local.maven_cache_location
  iam_role           = module.publish_release_role.role_arn
  kms_key            = var.management_kms_arn
  build_timeout      = 60
  log_retention_days = var.log_retention_days

  tags = local.tags
}

module "pull_request_codebuild" {
  source = "./modules/pull_request_codebuild"

  count = var.environment == "build" ? 1 : 0

  name               = "${local.build_prefix}-pull-request"
  buildspec          = templatefile("${path.module}/buildspecs/pull_request_build.yml", {
    application_name                           = var.git_project_name
    git_project_name                           = var.git_project_name
    sonarcloud_secret_sonarcloud_scanner_zip   = var.sonarcloud_secrets.sonarcloud_scanner_zip_path
    sonarcloud_secret_sonarcloud_settings_path = var.sonarcloud_secrets.sonarcloud_settings_path
    sonarcloud_secret_sonarcloud_endpoint      = var.sonarcloud_secrets.sonarcloud_endpoint
    sonarcloud_secret_sonarcloud_organisation  = var.sonarcloud_secrets.sonarcloud_organisation
    sonarcloud_secret_sonarcloud_token         = var.sonarcloud_secrets.sonarcloud_token
    maven_settings_path                        = var.maven_secrets.maven_settings_path
    jfrog_secret_release_repo                  = var.jfrog_secrets.release_repo
    jfrog_secret_snapshot_repo                 = var.jfrog_secrets.snapshot_repo
    jfrog_secret_release_local_repo            = var.jfrog_secrets.release_local_repo
    jfrog_secret_snapshot_local_repo           = var.jfrog_secrets.snapshot_local_repo
    jfrog_secret_username                      = var.jfrog_secrets.username
    jfrog_secret_token                         = var.jfrog_secrets.token
    github_repo                                = "${var.git_organisation}/${var.git_project_name}"
  })
  cache_location     = local.maven_cache_location
  git_url            = "https://github.com/${var.git_organisation}/${var.git_project_name}.git"
  git_account_id     = local.pipeline_secrets[var.git_secrets_keys.account_id]
  git_branch         = var.git_branch
  iam_role           = module.pull_request_role.role_arn
  kms_key            = var.management_kms_arn
  log_retention_days = var.log_retention_days

  tags = local.tags
}

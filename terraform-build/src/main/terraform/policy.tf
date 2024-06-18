module "source_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-source"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policies    = {
    "logging-access"     = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access" = data.aws_iam_policy_document.pipeline_s3.json
  }

  tags = local.tags
}

module "build_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-build"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policies    = {
    "logging-access"         = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access"     = data.aws_iam_policy_document.pipeline_s3.json
    "secrets-manager-access" = data.aws_iam_policy_document.secrets_manager.json
    "shared-s3-access"       = data.aws_iam_policy_document.shared_s3.json
  }

  tags = local.tags
}

module "quality_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-quality"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policies    = {
    "logging-access"         = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access"     = data.aws_iam_policy_document.pipeline_s3.json
    "secrets-manager-access" = data.aws_iam_policy_document.secrets_manager.json
    "shared-s3-access"       = data.aws_iam_policy_document.shared_s3.json
  }

  tags = local.tags
}

module "publish_release_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-publish-release"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policies    = {
    "logging-access"         = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access"     = data.aws_iam_policy_document.pipeline_s3.json
    "secrets-manager-access" = data.aws_iam_policy_document.secrets_manager.json
    "shared-s3-access"       = data.aws_iam_policy_document.shared_s3.json
  }

  tags = local.tags
}

module "deploy_release_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-deploy-release"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  can_assume_self    = true
  inline_policies    = {
    "logging-access"                = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access"            = data.aws_iam_policy_document.pipeline_s3.json
    "shared-s3-access"              = data.aws_iam_policy_document.shared_s3.json
    "terraform-remote-state-access" = data.aws_iam_policy_document.terraform_remote_state.json
    "infrastructure-access"         = data.aws_iam_policy_document.deploy_release_infrastructure.json
    "release-pipeline-s3-access"    = data.aws_iam_policy_document.release_pipeline_s3.json
    "codepipeline-access"           = data.aws_iam_policy_document.trigger_codepipeline.json
  }

  tags = local.tags
}

module "test_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-test"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  can_assume_self    = true
  inline_policies    = {
    "logging-access"                = data.aws_iam_policy_document.logging.json
    "vpc-access"                    = data.aws_iam_policy_document.vpc.json
    "pipeline-s3-access"            = data.aws_iam_policy_document.pipeline_s3.json
    "secrets-manager-access"        = data.aws_iam_policy_document.secrets_manager.json
    "shared-s3-access"              = data.aws_iam_policy_document.shared_s3.json
    "terraform-remote-state-access" = data.aws_iam_policy_document.terraform_remote_state.json
    "infrastructure-access"         = data.aws_iam_policy_document.deploy_acceptance_infrastructure.json
    "acceptance-access"             = data.aws_iam_policy_document.acceptance.json
  }

  tags = local.tags
}

module "pipeline_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-pipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  inline_policies    = {
    "pipeline-s3-access"       = data.aws_iam_policy_document.pipeline_s3.json
    "codebuild-access"         = data.aws_iam_policy_document.codebuild.json
    "publish-artifacts-access" = data.aws_iam_policy_document.publish_artifacts.json
  }

  tags = local.tags
}

module "pull_request_role" {
  source = "./modules/iam_role"

  name               = "${local.build_prefix}-pull-request"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policies    = {
    "logging-access"         = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access"     = data.aws_iam_policy_document.pipeline_s3.json
    "secrets-manager-access" = data.aws_iam_policy_document.secrets_manager.json
    "shared-s3-access"       = data.aws_iam_policy_document.shared_s3.json
  }

  tags = local.tags
}

data aws_iam_policy_document logging {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

// https://docs.aws.amazon.com/codebuild/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html#customer-managed-policies-example-create-vpc-network-interface
data aws_iam_policy_document vpc {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${local.aws_region}:${local.aws_account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }

  }
}

data aws_iam_policy_document pipeline_s3 {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "s3:GetBucketPolicy",
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
      module.pipeline_bucket.bucket_arn,
      "${module.pipeline_bucket.bucket_arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.management_kms_arn]
  }
}

data aws_iam_policy_document secrets_manager {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.pipeline_secret_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [var.pipeline_secret_kms_key]
  }
}

data aws_iam_policy_document shared_s3 {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.release_bucket_arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [var.release_bucket_kms_key]
  }
}

data aws_iam_policy_document release_pipeline_s3 {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.pipeline_bucket.bucket_arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey"]
    resources = [var.management_kms_arn]
  }
}

data aws_iam_policy_document terraform_remote_state {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      var.environment_remote_state_bucket_arn,
      "${var.environment_remote_state_bucket_arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [var.environment_remote_state_table_arn]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.management_kms_arn]
  }
}

data aws_iam_policy_document deploy_release_infrastructure {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    // TODO: Tighten this down
    actions   = [
      "s3:*",
      "iam:*",
      "codepipeline:*",
      "codebuild:*",
      "logs:*",
      "ssm:*"
    ]
    resources = ["*"]
  }
}

data aws_iam_policy_document trigger_codepipeline {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "codepipeline:GetPipelineExecution",
      "codepipeline:StartPipelineExecution"
    ]
    resources = [
      "arn:aws:codepipeline:${local.aws_region}:${local.aws_account_id}:${local.prefix}-release"
    ]
  }
}

data aws_iam_policy_document codebuild {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = [
      "arn:aws:codebuild:${local.aws_region}:${local.aws_account_id}:project/${local.build_prefix}-*"
    ]
  }
}

data aws_iam_policy_document deploy_acceptance_infrastructure {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "apigateway:*",
      "cognito-idp:*",
      "ssm:*"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [var.management_kms_arn]
  }
}

data aws_iam_policy_document acceptance {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:${local.aws_region}:${local.aws_account_id}:parameter${local.acceptance_root_parameter_path}/*",
      "arn:aws:ssm:${local.aws_region}:${local.aws_account_id}:parameter${local.root_parameter_path}/*"
    ]
  }
}

data aws_iam_policy_document publish_artifacts {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${var.release_bucket_arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.release_bucket_kms_key]
  }
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.aws_account_id}:root"]
    }
  }
}

data aws_iam_policy_document "codepipeline_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

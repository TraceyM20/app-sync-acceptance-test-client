module "prepare_role" {
  source = "./modules/iam_role"

  name               = "${local.release_prefix}-prepare"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policies    = {
    "logging-access"     = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access" = data.aws_iam_policy_document.pipeline_s3.json
    "shared-s3-access"   = data.aws_iam_policy_document.shared_s3.json
  }

  tags = local.tags
}

module "deploy_infrastructure_role" {
  source = "./modules/iam_role"

  name               = "${local.release_prefix}-infrastructure"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  can_assume_self    = true
  inline_policies    = {
    "logging-access"                = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access"            = data.aws_iam_policy_document.pipeline_s3.json
    "terraform-remote-state-access" = data.aws_iam_policy_document.terraform_remote_state.json
    "infrastructure-access"         = data.aws_iam_policy_document.deploy_infrastructure.json
  }

  tags = local.tags
}

module "deploy_application_role" {
  source = "./modules/iam_role"

  name               = "${local.release_prefix}-application"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  inline_policies    = {
    "logging-access"                = data.aws_iam_policy_document.logging.json
    "pipeline-s3-access"            = data.aws_iam_policy_document.pipeline_s3.json
    "api-gateway-management-access" = data.aws_iam_policy_document.api_gateway_management.json
    "pipeline-lambda-access" = data.aws_iam_policy_document.pipeline_lambda.json
  }

  tags = local.tags
}

module "pipeline_role" {
  source = "./modules/iam_role"

  name               = "${local.release_prefix}-pipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  inline_policies    = {
    "pipeline-s3-access"            = data.aws_iam_policy_document.pipeline_s3.json
    "codebuild-access"              = data.aws_iam_policy_document.codebuild.json
    "api-gateway-management-access" = data.aws_iam_policy_document.api_gateway_management.json
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
      "arn:aws:s3:::${var.config_s3_name}",
      "arn:aws:s3:::${var.config_s3_name}/*"
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

data aws_iam_policy_document deploy_infrastructure {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "s3:*",
      "dynamodb:*",
      "kms:*",
      "sts:*",
      "route53:*",
      "iam:*",
      "acm:*",
      "apigateway:*",
      "logs:*",
      "wafv2:*",
      "sns:*",
      "ssm:*",
      "lambda:*",
      "ec2:*",
      "cognito-idp:*",
    ]
    resources = ["*"]
  }
}

data aws_iam_policy_document pipeline_lambda {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "lambda:UpdateFunctionCode",
      "lambda:PublishVersion",
      "lambda:UpdateAlias",
      "lambda:ListVersionsByFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = ["*"]
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


data aws_iam_policy_document shared_s3 {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    // TODO: Tighten this down to specific project(s)
    resources = ["*"]
  }
}

data aws_iam_policy_document ssm {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${local.aws_region}:${local.aws_account_id}:parameter${local.root_parameter_path}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [
      var.management_kms_arn,
      var.application_kms_arn
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
      "arn:aws:codebuild:${local.aws_region}:${local.aws_account_id}:project/${local.release_prefix}-*"
    ]
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

data "aws_iam_policy_document" "api_gateway_management" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = [
      "apigateway:GET",
      "apigateway:POST",
      "apigateway:DELETE"
    ]
    resources = [
      "arn:aws:apigateway:${local.aws_region}::/restapis/*/deployments",
      "arn:aws:apigateway:${local.aws_region}::/restapis/*/deployments/*",
      "arn:aws:apigateway:${local.aws_region}::/restapis/*/stages/${local.prefix}-rest-endpoint-environment"
    ]
  }
}

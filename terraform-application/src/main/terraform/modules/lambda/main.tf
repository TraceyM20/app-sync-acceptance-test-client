locals {
  role_name           = "${var.name}-role"
  vpc_policies        =    concat(var.managed_policy_arns, ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"])
  basic_policies      =    concat(var.managed_policy_arns, ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"])
  managed_policy_arns = var.vpc_configuration != null ? local.vpc_policies : local.basic_policies
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  filename      = data.archive_file.lambda_zip.output_path
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory
  timeout       = var.timeout
  role          = aws_iam_role.this.arn
  publish       = false

  dynamic "vpc_config" {
    for_each = var.vpc_configuration != null ? [0] : []

    content {
      subnet_ids         = var.vpc_configuration.subnet_ids
      security_group_ids = var.vpc_configuration.security_group_ids
    }
  }

  environment {
    variables = var.environment_variables
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lambda_alias" "this" {
  name             = var.alias_name
  function_name    = aws_lambda_function.this.function_name
  function_version = "$LATEST"

  lifecycle {
    ignore_changes = [function_version]
  }
}


module "lambda_assume_role" {
  source = "../../fragments/policy/lambda"

  statements = [
    {
      effect    = "Allow"
      actions   = ["sts:AssumeRole"]
      sid       = "AllowAssumeRoleLambda"

      principals = {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
    }
  ]
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = module.lambda_assume_role.policy_document_json

  tags = merge(var.tags, {
    Name = local.role_name
  })
}

// Managed policy attachments
resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(local.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

// Inline policies
resource "aws_iam_role_policy" "this" {
  for_each = var.inline_policies

  role   = aws_iam_role.this.id
  name   = each.key
  policy = each.value
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-logs"
  })
}

data "archive_file" "lambda_zip" {
  output_path = "/tmp/lambda.zip"
  type        = "zip"

  source {
    content  = "<<EOF"
    filename = "empty.txt"
  }
}

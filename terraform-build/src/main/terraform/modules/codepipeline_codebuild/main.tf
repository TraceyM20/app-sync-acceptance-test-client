resource "aws_codebuild_project" "this" {
  name           = var.name
  service_role   = var.iam_role
  build_timeout  = var.build_timeout
  encryption_key = var.kms_key

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  dynamic "cache" {
    for_each = var.cache_location != "" ? [0] : []

    content {
      type     = "S3"
      location = var.cache_location
    }
  }

  environment {
    compute_type = var.compute_type
    image        = var.image
    type         = var.container_type
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [
      var.vpc_config
    ] : []

    content {
      vpc_id             = var.vpc_config.vpc_id
      subnets            = var.vpc_config.subnets
      security_group_ids = [var.vpc_config.security_group_id]
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/codebuild/${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-logs"
  })
}

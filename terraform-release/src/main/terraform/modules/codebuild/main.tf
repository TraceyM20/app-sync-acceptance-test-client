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

  environment {
    compute_type = var.compute_type
    image        = var.image
    type         = var.container_type
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

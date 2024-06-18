resource "aws_codebuild_project" "this" {
  name           = var.name
  service_role   = var.iam_role
  build_timeout  = var.build_timeout
  encryption_key = var.kms_key
  source_version = var.git_branch

  source {
    type      = "GITHUB"
    location  = var.git_url
    buildspec = var.buildspec
  }

  artifacts {
    type      = "S3"
    location  = var.output_bucket_name
    name      = var.output_bucket_key
    packaging = "ZIP"
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

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_codebuild_webhook" "this" {
  project_name = aws_codebuild_project.this.name

  filter_group {
    filter {
      pattern = ".*/${var.git_branch}"
      type    = "HEAD_REF"
    }

    filter {
      pattern = "PUSH,PULL_REQUEST_MERGED"
      type    = "EVENT"
    }

    filter {
      exclude_matched_pattern = true
      pattern                 = var.git_account_id
      type                    = "ACTOR_ACCOUNT_ID"
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/codebuild/${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-logs"
  })
}

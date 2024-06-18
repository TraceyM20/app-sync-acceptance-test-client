resource "aws_codebuild_project" "this" {
  name           = var.name
  service_role   = var.iam_role
  build_timeout  = var.build_timeout
  encryption_key = var.kms_key
  source_version = var.git_branch
  badge_enabled  = true

  source {
    type                = "GITHUB"
    location            = var.git_url
    buildspec           = var.buildspec
    git_clone_depth     = 1
    report_build_status = true
  }

  artifacts {
    type = "NO_ARTIFACTS"
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
      pattern = "PULL_REQUEST_CREATED, PULL_REQUEST_UPDATED, PULL_REQUEST_REOPENED"
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

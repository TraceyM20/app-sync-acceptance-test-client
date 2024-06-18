resource "aws_codepipeline" "this" {
  name     = var.name
  role_arn = var.iam_role

  artifact_store {
    type     = "S3"
    location = var.bucket_name

    encryption_key {
      type = "KMS"
      id   = var.kms_key
    }
  }

  stage {
    name = "Source"

    action {
      name             = "S3"
      category         = "Source"
      provider         = "S3"
      owner            = "AWS"
      version          = "1"
      output_artifacts = ["Source"]
      configuration    = {
        S3Bucket             = var.bucket_name
        S3ObjectKey          = var.source_object_key
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "MavenBuild"
      category         = "Build"
      provider         = "CodeBuild"
      owner            = "AWS"
      version          = "1"
      namespace        = "MavenBuildVariables"
      input_artifacts  = ["Source"]
      output_artifacts = [
        "SnapshotArtifacts",
        "SnapshotArtifactsAll"
      ]
      configuration    = {
        ProjectName = var.maven_build_codebuild
      }
    }
  }

  stage {
    name = "Quality"

    action {
      name            = "SonarCloud"
      category        = "Test"
      provider        = "CodeBuild"
      owner           = "AWS"
      version         = "1"
      input_artifacts = ["SnapshotArtifactsAll"]
      configuration   = {
        ProjectName          = var.code_quality_codebuild
        EnvironmentVariables = jsonencode([
          {
            name  = "MAVEN_VERSION_NUMBER",
            value = "#{MavenBuildVariables.VERSION_NUMBER}"
          }
        ])
      }
    }
  }

  stage {
    name = "DeployRelease"

    action {
      name            = "DeployReleasePipeline"
      category        = "Build"
      provider        = "CodeBuild"
      owner           = "AWS"
      run_order       = 1
      version         = "1"
      namespace       = "TerraformStateVariables"
      input_artifacts = ["SnapshotArtifacts"]
      configuration   = {
        ProjectName = var.deploy_release_pipeline_codebuild
      }
    }

    action {
      name            = "BundleReleasePipelineConfig"
      category        = "Build"
      provider        = "CodeBuild"
      owner           = "AWS"
      run_order       = 2
      version         = "1"
      input_artifacts = ["SnapshotArtifacts"]
      configuration   = {
        ProjectName          = var.bundle_release_pipeline_config_codebuild
        EnvironmentVariables = jsonencode([
          {
            name  = "MAVEN_VERSION_NUMBER",
            value = "#{MavenBuildVariables.VERSION_NUMBER}"
          }
        ])
      }
    }

    action {
      name            = "TriggerReleasePipeline"
      category        = "Build"
      provider        = "CodeBuild"
      owner           = "AWS"
      run_order       = 3
      version         = "1"
      input_artifacts = ["SnapshotArtifacts"]
      configuration   = {
        ProjectName          = var.trigger_release_pipeline_codebuild
        EnvironmentVariables = jsonencode([
          {
            name  = "RELEASE_PIPELINE_NAME",
            value = "#{TerraformStateVariables.RELEASE_PIPELINE_NAME}"
          }
        ])
      }
    }
  }

  stage {
    name = "Test"

    action {
      name            = "DeployAcceptance"
      category        = "Build"
      provider        = "CodeBuild"
      owner           = "AWS"
      run_order       = 1
      version         = "1"
      input_artifacts = ["SnapshotArtifacts"]
      configuration   = {
        ProjectName = var.deploy_acceptance_codebuild
      }
    }

    action {
      name            = "AcceptanceTest"
      category        = "Build"
      provider        = "CodeBuild"
      owner           = "AWS"
      run_order       = 2
      version         = "1"
      input_artifacts = ["Source"]
      configuration   = {
        ProjectName = var.acceptance_codebuild
      }
    }
  }

  stage {
    name = "PublishRelease"

    action {
      name             = "MavenRelease"
      category         = "Build"
      provider         = "CodeBuild"
      owner            = "AWS"
      run_order        = 1
      version          = "1"
      namespace        = "MavenReleaseVariables"
      input_artifacts  = ["Source"]
      output_artifacts = ["ReleaseArtifacts"]
      configuration    = {
        ProjectName = var.maven_release_codebuild
      }
    }

    action {
      name            = "S3Publish"
      category        = "Deploy"
      provider        = "S3"
      owner           = "AWS"
      run_order       = 2
      version         = "1"
      input_artifacts = ["ReleaseArtifacts"]
      configuration   = {
        BucketName          = var.release_bucket_name
        Extract             = true
        KMSEncryptionKeyARN = var.release_bucket_kms_key
      }
    }
  }

  provisioner "local-exec" {
    interpreter = ["sh", "-c"]
    command = <<EOT
      aws codepipeline disable-stage-transition \
      --pipeline-name ${var.name} \
      --stage-name PublishRelease \
      --transition-type Inbound \
      --reason "RELEASE SHOULD NOT BE ENABLED OUTSIDE OF BUILD ENVIRONMENT" \
      --profile ${var.profile_name}
    EOT
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

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
        S3ObjectKey          = var.object_key
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "DeployInfrastructure"

    action {
      name            = "DeployInfrastructure"
      category        = "Build"
      provider        = "CodeBuild"
      owner           = "AWS"
      version         = "1"
      namespace       = "TerraformStateVariables"
      input_artifacts = ["Source"]
      configuration   = {
        ProjectName = var.deploy_infrastructure_codebuild
      }
    }
  }

  stage {
    name = "DeployApplication"

    dynamic "action" {
      for_each = var.deploy_lambda_codebuilds

      content {
        name            = action.key
        category        = "Build"
        provider        = "CodeBuild"
        owner           = "AWS"
        run_order       = 1
        version         = "1"
        input_artifacts = ["Source"]
        configuration   = {
          ProjectName          = action.value["codebuild_name"]
          EnvironmentVariables = jsonencode([
            {
              name  = "LAMBDA_ARN",
              value = "#{TerraformStateVariables.${action.value["lambda_arn_variable"]}}"
            }
          ])
        }
      }
    }

    action {
      name            = "DeployApiGateway"
      category        = "Build"
      provider        = "CodeBuild"
      owner           = "AWS"
      version         = "1"
      input_artifacts = ["Source"]
      configuration   = {
        ProjectName          = var.deploy_api_gateway_codebuild
        EnvironmentVariables = jsonencode([
          {
            name  = "API_GATEWAY_ID",
            value = "#{TerraformStateVariables.BASE_API_GATEWAY_ID}"
          },
          {
            name  = "API_GATEWAY_STAGE_NAME",
            value = "#{TerraformStateVariables.BASE_API_GATEWAY_STAGE_NAME}"
          }
        ])
      }
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

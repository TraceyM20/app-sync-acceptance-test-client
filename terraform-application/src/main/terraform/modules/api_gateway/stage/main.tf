resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.api_id
  description = "Initial deployment"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  depends_on = [aws_api_gateway_deployment.this]

  rest_api_id   = var.api_id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.name

  access_log_settings {
    destination_arn = var.log_group_arn
    format          = jsonencode({
      caller         = "$context.identity.caller"
      httpMethod     = "$context.httpMethod"
      ip             = "$context.identity.sourceIp"
      protocol       = "$context.protocol"
      requestId      = "$context.requestId"
      requestTime    = "$context.requestTime"
      resourcePath   = "$context.resourcePath"
      responseLength = "$context.responseLength"
      status         = "$context.status"
      user           = "$context.identity.user"
    })
  }

  lifecycle {
    ignore_changes = [
      cache_cluster_size,
      deployment_id
    ]
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = var.api_id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    logging_level   = "INFO"
    metrics_enabled = true
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  web_acl_arn  = var.web_acl_arn
  resource_arn = aws_api_gateway_stage.this.arn
}

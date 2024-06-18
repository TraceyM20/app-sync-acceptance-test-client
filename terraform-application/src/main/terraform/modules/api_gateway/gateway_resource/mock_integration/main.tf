module "resource" {
  source = "../"

  api_id             = var.api_id
  parent_resource_id = var.parent_resource_id
  path               = var.path
  methods            = var.methods
  authorizer_id      = var.authorizer_id
}

resource "aws_api_gateway_integration" "this" {
  depends_on = [module.resource]

  for_each = var.methods

  rest_api_id          = var.api_id
  resource_id          = module.resource.resource_id
  http_method          = each.key
  type                 = "MOCK"
  passthrough_behavior = "NEVER"
  request_templates    = {
    "application/json" = jsonencode({
      statusCode = 200
    })
    "text/plain": jsonencode({
      statusCode = 200
    })
    "multipart/form-data": jsonencode({
      statusCode = 200
    })
    "application/x-www-form-urlencoded": jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "this" {
  depends_on = [aws_api_gateway_integration.this]

  for_each = var.methods

  rest_api_id = var.api_id
  resource_id = module.resource.resource_id
  http_method = each.key
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "this" {
  depends_on = [aws_api_gateway_integration.this]

  for_each = var.methods

  rest_api_id        = var.api_id
  resource_id        = module.resource.resource_id
  http_method        = each.key
  selection_pattern  = "2\\d{2}"
  status_code        = "200"
  response_templates = {
    "application/json" = <<EOF
#set($allParams=$input.params()) {"params": {#foreach($type in $allParams.keySet()) #set($params=$allParams.get($type)) "$type": {#foreach($paramName in $params.keySet()) #if($paramName!="Authorization" && $paramName!="x-edge-identification-key") "$paramName":"$util.escapeJavaScript($params.get($paramName))" #if($foreach.hasNext),#end #end #end} #if($foreach.hasNext),#end #end}, "context": {"http-method": "$context.httpMethod", "source-ip": "$context.identity.sourceIp", "user": "$context.identity.user", "user-agent": "$context.identity.userAgent", "user-arn": "$context.identity.userArn", "request-id": "$context.requestId", "resource-path": "$context.resourcePath"}}
EOF
  }
}

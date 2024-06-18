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

  rest_api_id             = var.api_id
  resource_id             = module.resource.resource_id
  http_method             = each.key
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_invoke_arn
}

resource "aws_lambda_permission" "this" {
  depends_on = [module.resource]

  for_each = var.methods

  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  qualifier     = "action-target"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.aws_region}:${local.aws_account_id}:${var.api_id}/${var.stage_name}/${each.key}${module.resource.full_path}"
}

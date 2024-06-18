resource "aws_api_gateway_resource" "this" {
  rest_api_id = var.api_id
  parent_id   = var.parent_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "this" {
  for_each = var.methods

  rest_api_id           = var.api_id
  resource_id           = aws_api_gateway_resource.this.id
  http_method           = each.key
  api_key_required      = true
  authorization         = var.authorizer_id != null ? "COGNITO_USER_POOLS" : "NONE"
  authorizer_id         = var.authorizer_id
  authorization_scopes  = var.authorizer_id != null ? each.value.cognito_scopes : []
}

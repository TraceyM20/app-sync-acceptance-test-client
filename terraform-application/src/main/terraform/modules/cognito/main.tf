resource "aws_cognito_resource_server" "resource" {
  name         = var.name
  user_pool_id = var.user_pool_id
  identifier   = var.identifier

  dynamic "scope" {
    for_each = var.scopes

    content {
      scope_name        = scope.key
      scope_description = scope.value
    }
  }
}

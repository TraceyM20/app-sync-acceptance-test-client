// health
module "health" {
  source = "../gateway_resource/mock_integration"

  api_id             = var.api_id
  parent_resource_id = var.parent_resource_id
  path               = "health"
  methods            = {
    "GET" = {
      cognito_scopes = []
    }
  }
}

// health/secure
module "secure_health" {
  source = "../gateway_resource/mock_integration"

  api_id             = var.api_id
  parent_resource_id = module.health.resource_id
  path               = "secure"
  methods            = {
    "ANY" = {
      cognito_scopes = var.cognito_scopes
    }
  }
  authorizer_id      = var.authorizer_id
}


module "api_gateway_integration_helloworld" {
  source                = "../../gateway_resource/lambda_integration"

  api_id                = var.api_id
  parent_resource_id    = var.parent_resource_id
  path                  = "helloworld"
  methods               = {
    "POST" = var.lambda_integrations["hello"]
  }
  authorizer_id         = var.authorizer_id
  stage_name            = var.stage_name
}

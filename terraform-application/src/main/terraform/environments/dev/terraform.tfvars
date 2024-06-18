service_name        = "vts-nep"
component_name      = "new-project-template"
environment         = "dev"
application_kms_arn = "arn:aws:kms:ap-southeast-2:473411030665:key/66133723-353e-4e60-9a23-cc148da2c577"
cost_group          = "meteringau-nep"
created_by          = "terraform: manual"
owner               = "nep.operations@vector.co.nz"
log_level           = "INFO"
log_retention_days  = 1

parameter_store_values = {
  "timezone/business" = {
    value = "Pacific/Auckland"
    type  = "String"
  }
  "timezone/quantity" = {
    value = "+12:00"
    type  = "String"
  }
  "timezone/system" = {
    value = "UTC"
    type  = "String"
  }
}

wiremock_configuration = {
  vpc_id     = "vpc-09709a0bfbb651f2a"
  subnet_ids = [
    "subnet-038b476a7e58ca4e1",
    "subnet-09c4b4df8346088ec",
    "subnet-081f6c37da1b1c10e"
  ]
}

cognito_user_pool_arn = "arn:aws:cognito-idp:ap-southeast-2:473411030665:userpool/ap-southeast-2_8OpBWkNb0"
cognito_user_pool_id  = "ap-southeast-2_8OpBWkNb0"
hosted_zone_id        = "Z10385973OI7C5MMIR5ON"
domain_name           = "new-project-template.origin.dev.nep.vts.nz"
web_acl_arn           = "arn:aws:wafv2:ap-southeast-2:473411030665:regional/webacl/vm-nz-mip-dev-access-control/3883acd6-1918-49cc-85fe-2acca9fdd69c"

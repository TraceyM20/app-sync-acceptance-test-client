output "scope_identifiers" {
  description = "A map of all scopes configured for this resource server. Key = scope name. Value = the fully qualified scope identifier in the format identifier/scope_name"
  value       = zipmap(
    [for identifier in aws_cognito_resource_server.resource.scope_identifiers : regex("${var.identifier}\\/(.*)+", identifier)[0]],
    aws_cognito_resource_server.resource.scope_identifiers
  )
}

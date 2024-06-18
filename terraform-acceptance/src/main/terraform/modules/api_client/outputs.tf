output "api_key" {
  value     = aws_api_gateway_api_key.this.value
  sensitive = true
}

output "client_id" {
  value     = aws_cognito_user_pool_client.this.id
  sensitive = true
}

output "client_secret" {
  value     = aws_cognito_user_pool_client.this.client_secret
  sensitive = true
}

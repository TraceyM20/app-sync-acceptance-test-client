output "resource_id" {
  value = aws_api_gateway_resource.this.id
}

output "full_path" {
  value = aws_api_gateway_resource.this.path
}

output "methods" {
  value = aws_api_gateway_method.this
}

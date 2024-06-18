output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "alias_arn" {
  value = aws_lambda_alias.this.arn
}

output "alias_invoke_arn" {
  value = aws_lambda_alias.this.invoke_arn
}

output "lambda_role_arn" {
  value = aws_iam_role.this.arn
}

output "lambda_role_id" {
  value = aws_iam_role.this.id
}

output "lambda_role_name" {
  value = aws_iam_role.this.name
}

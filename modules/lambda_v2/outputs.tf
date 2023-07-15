output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "lambda_iam_role_name" {
  value = aws_iam_role.this.name
}
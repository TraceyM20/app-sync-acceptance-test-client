resource "aws_iam_role" "this" {
  name = "${var.name}_api_gateway_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["apigateway.amazonaws.com", "lambda.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "${var.name}_lambda_policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

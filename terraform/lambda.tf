locals {
  source_file   = "${path.module}/../src/main.js"
  output_path   = "${path.module}/tmp/cognito_lambda.zip"
  function_name = "cognito_lambda"
}

data "archive_file" "cognito_lambda" {
  type        = "zip"
  source_file = local.source_file
  output_path = local.output_path
}

resource "aws_iam_role" "cognito_lambda_role" {
  name = "cognito_lambda_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_lambda_function" "cognito_lambda" {
  filename         = local.output_path
  function_name    = local.function_name
  role             = aws_iam_role.cognito_lambda_role.arn
  handler          = "main.handler"
  source_code_hash = data.archive_file.cognito_lambda.output_base64sha256
  runtime          = "nodejs12.x"
}

variable "account_id" {}

variable "allow_headers" {
  description = "Allow headers"
  type        = list(string)

  default = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key",
  ]
}

# var.allow_methods
variable "allow_methods" {
  description = "Allow methods"
  type        = list(string)

  default = [
    "OPTIONS",
    "HEAD",
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
  ]
}

# var.allow_origin
variable "allow_origin" {
  description = "Allow origin"
  type        = string
  default     = "*"
}

# var.allow_max_age
variable "allow_max_age" {
  description = "Allow response caching time"
  type        = string
  default     = "7200"
}

# var.allowed_credentials
variable "allow_credentials" {
  description = "Allow credentials"
  default     = false
}

locals {
  name        = "cognito_api"
  description = "API with Cognito"
  path_part   = "cognito"
  headers = map(
    "Access-Control-Allow-Headers", "'${join(",", var.allow_headers)}'",
    "Access-Control-Allow-Methods", "'${join(",", var.allow_methods)}'",
    "Access-Control-Allow-Origin", "'${var.allow_origin}'",
    "Access-Control-Max-Age", "'${var.allow_max_age}'",
    "Access-Control-Allow-Credentials", var.allow_credentials ? "'true'" : ""
  )

  # Pick non-empty header values
  header_values = compact(values(local.headers))

  # Pick names that from non-empty header values
  header_names = matchkeys(
    keys(local.headers),
    values(local.headers),
    local.header_values
  )

  # Parameter names for method and integration responses
  parameter_names = formatlist("method.response.header.%s", local.header_names)

  # Map parameter list to "true" values
  true_list = split("|",
    replace(join("|", local.parameter_names), "/[^|]+/", "true")
  )

  # Integration response parameters
  integration_response_parameters = zipmap(
    local.parameter_names,
    local.header_values
  )

  # Method response parameters
  method_response_parameters = zipmap(
    local.parameter_names,
    local.true_list
  )
}

# This creates an empty API Gateway without any resources
resource "aws_api_gateway_rest_api" "cognito_api" {
  name        = local.name
  description = local.description
}

# This creates the resource within api gateway
resource "aws_api_gateway_resource" "cognito_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.cognito_api.id
  parent_id   = aws_api_gateway_rest_api.cognito_api.root_resource_id
  path_part   = local.path_part
}

# This creates the GET method to access the API
resource "aws_api_gateway_method" "cognito_api_method_get" {
  rest_api_id   = aws_api_gateway_rest_api.cognito_api.id
  resource_id   = aws_api_gateway_resource.cognito_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "cognito_api_method_options" {
  rest_api_id   = aws_api_gateway_rest_api.cognito_api.id
  resource_id   = aws_api_gateway_resource.cognito_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# This creates the integration with lambda
resource "aws_api_gateway_integration" "cognito_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cognito_api.id
  resource_id             = aws_api_gateway_resource.cognito_api_resource.id
  http_method             = aws_api_gateway_method.cognito_api_method_get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  content_handling        = "CONVERT_TO_TEXT"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = aws_lambda_function.cognito_lambda.invoke_arn
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_integration" "cognito_api_integration_options" {
  rest_api_id             = aws_api_gateway_rest_api.cognito_api.id
  resource_id             = aws_api_gateway_resource.cognito_api_resource.id
  http_method             = aws_api_gateway_method.cognito_api_method_options.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  content_handling        = "CONVERT_TO_TEXT"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = aws_lambda_function.cognito_lambda.invoke_arn
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "cognito_api_gateway_method_response" {
  rest_api_id = aws_api_gateway_rest_api.cognito_api.id
  resource_id = aws_api_gateway_resource.cognito_api_resource.id
  http_method = aws_api_gateway_method.cognito_api_method_get.http_method
  status_code = 200

  response_parameters = local.method_response_parameters

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.cognito_api_method_get,
  ]
}

resource "aws_api_gateway_integration_response" "cognito_api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.cognito_api.id
  resource_id = aws_api_gateway_resource.cognito_api_resource.id
  http_method = aws_api_gateway_method.cognito_api_method_get.http_method
  status_code = 200

  response_parameters = local.integration_response_parameters

  depends_on = [
    aws_api_gateway_integration.cognito_api_integration,
    aws_api_gateway_method_response.cognito_api_gateway_method_response,
  ]
}

# This gives permission to API Gateway to execute lambda
resource "aws_lambda_permission" "cognito_api_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.cognito_api.id}/*/${aws_api_gateway_method.cognito_api_method_get.http_method}${aws_api_gateway_resource.cognito_api_resource.path}"
}

# This adds the deployment to expose the API
resource "aws_api_gateway_deployment" "cognito_api_deployment" {
  depends_on  = [aws_api_gateway_integration.cognito_api_integration]
  rest_api_id = aws_api_gateway_rest_api.cognito_api.id
  stage_name  = "test"
}

# Prints the output URL
output "get_url" {
  value = "${aws_api_gateway_deployment.cognito_api_deployment.invoke_url}/${local.path_part}"
}

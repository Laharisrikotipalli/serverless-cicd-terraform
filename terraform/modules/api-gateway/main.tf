data "aws_region" "current" {}

# ------------------------
# REST API
# ------------------------
resource "aws_api_gateway_rest_api" "this" {
  name = var.api_name
  tags = var.tags
}

# ------------------------
# /hello resource
# ------------------------
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "hello"
}

# ------------------------
# GET /hello method
# ------------------------
resource "aws_api_gateway_method" "get_hello" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.hello.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

# ------------------------
# Lambda proxy integration
# ------------------------
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.get_hello.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

# ------------------------
# Lambda permission
# IMPORTANT:
# - Use FUNCTION NAME (not ARN)
# - Works for blue/green aliases
# ------------------------
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvokeAlias"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn   # alias ARN
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}


# ------------------------
# Deployment
# FORCE redeploy on alias change
# ------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeploy = sha1(var.lambda_function_arn)
  }

  depends_on = [
    aws_api_gateway_method.get_hello,
    aws_api_gateway_integration.lambda
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------
# Stage
# ------------------------
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name
  tags          = var.tags
}
# ------------------------
# API Key
# ------------------------
resource "aws_api_gateway_api_key" "this" {
  name    = "${var.api_name}-key"
  enabled = true
  tags    = var.tags
}

# ------------------------
# Usage Plan
# ------------------------
resource "aws_api_gateway_usage_plan" "this" {
  name = "${var.api_name}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  tags = var.tags
}

# ------------------------
# Usage Plan Key attachment
# ------------------------
resource "aws_api_gateway_usage_plan_key" "this" {
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
}

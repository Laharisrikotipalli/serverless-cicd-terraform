terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment = "prod"
  tags = {
    Environment = "prod"
    Project     = "serverless-cicd"
    Owner       = "lahari"
  }
}

# Lambda
module "lambda" {
  source = "../../modules/lambda"

  function_name  = "hello-prod"
  source_path    = "../../../lambda-src/hello_function"
  environment    = local.environment
  lambda_version = "Green"
  tags           = local.tags
}

# Lambda Alias (GREEN)
resource "aws_lambda_alias" "green" {
  name             = "green"
  function_name    = module.lambda.function_name
  function_version = module.lambda.version
}

# API Gateway
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name             = "hello-api-prod"
  stage_name           = local.environment
  lambda_function_arn  = aws_lambda_alias.green.arn
  lambda_function_name = module.lambda.function_name
  tags                 = local.tags
}

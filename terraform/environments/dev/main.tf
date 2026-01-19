terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  environment = "dev"
  tags = {
    Environment = local.environment
    Project     = var.project
    Owner       = var.owner
  }
}

module "lambda" {
  source = "../../modules/lambda"

  function_name   = "hello-dev"
  source_path     = "../../../lambda-src/hello_function"
  environment     = local.environment
  lambda_version  = "Blue"
  tags            = local.tags
}

module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name             = "hello-api-dev"
  stage_name           = local.environment
  lambda_function_arn  = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
  tags                 = local.tags
}


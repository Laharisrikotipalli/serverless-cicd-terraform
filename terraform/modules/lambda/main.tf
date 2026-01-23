
# Zip Lambda source

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.root}/.terraform-lambda/${var.function_name}.zip"
}


# Random suffix (Lambda names must be unique)

resource "random_id" "lambda_suffix" {
  byte_length = 4
}


# IAM Role for Lambda

resource "aws_iam_role" "lambda_role" {
  name_prefix = "${var.function_name}-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# Attach basic execution policy

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Lambda Function (REQUIRED function_name)

resource "aws_lambda_function" "this" {
  function_name = "${var.function_name}-${random_id.lambda_suffix.hex}"

  role    = aws_iam_role.lambda_role.arn
  handler = var.handler
  runtime = var.runtime

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  publish = true

  environment {
    variables = {
      ENVIRONMENT = var.environment
      VERSION     = var.lambda_version
    }
  }

  tags = var.tags
}

# CloudWatch Alarm

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${aws_lambda_function.this.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  tags = var.tags
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.root}/.terraform-lambda/${var.function_name}.zip"
}

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


resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "this" {
  function_name_prefix = "${var.function_name}-"

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


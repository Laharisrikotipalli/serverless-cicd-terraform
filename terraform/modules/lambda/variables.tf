variable "function_name" {
  type = string
}

variable "source_path" {
  type = string
}

variable "handler" {
  type    = string
  default = "app.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.11"
}

variable "environment" {
  type = string
}

variable "lambda_version" {
  type = string
}

variable "tags" {
  type = map(string)
}

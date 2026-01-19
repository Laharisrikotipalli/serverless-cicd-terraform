
output "invoke_url" {
  value = aws_api_gateway_stage.this.invoke_url
}

output "api_key" {
  value     = aws_api_gateway_api_key.this.value
  sensitive = true
}

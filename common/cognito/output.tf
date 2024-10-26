output "id" {
  description = "The id of the user pool"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].id : null
}

output "arn" {
  description = "The ARN of the user pool"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].arn : null
}

output "endpoint" {
  description = "The endpoint name of the user pool. Example format: cognito-idp.REGION.amazonaws.com/xxxx_yyyyy"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].endpoint : null
}

output "creation_date" {
  description = "The date the user pool was created"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].creation_date : null
}

output "last_modified_date" {
  description = "The date the user pool was last modified"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].last_modified_date : null
}

output "name" {
  description = "The name of the user pool"
  value       = var.enabled ? aws_cognito_user_pool.pool[0].name : null
}


#
# aws_cognito_user_pool_client
#
output "client_ids" {
  description = "The ids of the user pool clients"
  value       = var.enabled ? aws_cognito_user_pool_client.client.*.id : null
}

output "client_secrets" {
  description = " The client secrets of the user pool clients"
  value       = var.enabled ? aws_cognito_user_pool_client.client.*.client_secret : null
  sensitive   = true
}

output "client_ids_map" {
  description = "The ids map of the user pool clients"
  value       = var.enabled ? { for k, v in aws_cognito_user_pool_client.client : v.name => v.id } : null
}

output "client_secrets_map" {
  description = "The client secrets map of the user pool clients"
  value       = var.enabled ? { for k, v in aws_cognito_user_pool_client.client : v.name => v.client_secret } : null
  sensitive   = true
}
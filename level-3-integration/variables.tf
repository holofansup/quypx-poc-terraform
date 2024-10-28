### TAGS
variable "common_tags" {
  type        = map(string)
  default     = null
  description = "Default tags for all resources"
}

### COGNITO
variable "cognito_pools" {
  description = "List of Cognito user pool configurations"
  type = any
  default = null
}

variable "agw" {
  description = "API Gateway configuration"
  type = object({
    api_name = string
    api_description = string
    endpoint_configuration = object({
      types = string
      vpc_endpoint_ids = string
    })
    resource_path_part = string
    method_http_method = string
    cognito_pool_name = string
    integration_uri = string
    stage_name = string
  })
}
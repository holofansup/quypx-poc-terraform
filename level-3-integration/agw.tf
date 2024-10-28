locals {
  endpoint_configuration = {
    types = [upper(var.agw.endpoint_configuration.types)]
    vpc_endpoint_ids = upper(var.agw.endpoint_configuration.types) == "PRIVATE" ? [var.agw.endpoint_configuration.vpc_endpoint_ids] : null
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name        = var.agw.api_name
  description = var.agw.api_description
  endpoint_configuration {
    types = local.endpoint_configuration.types
    vpc_endpoint_ids = local.endpoint_configuration.vpc_endpoint_ids
  }
}

### Resources
resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.agw.resource_path_part
}

### Authorizers
resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "${var.agw.api_name}-cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.this.id
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [module.cognito[var.agw.cognito_pool_name].arn]
  type                   = "COGNITO_USER_POOLS"
}

output "method_authorization_scopes" {
  value = module.cognito[var.agw.cognito_pool_name].resource_servers_scope_identifiers
}

### Request Validator
resource "aws_api_gateway_request_validator" "this" {
  name = "${var.agw.api_name}-request-validator"
  rest_api_id = aws_api_gateway_rest_api.this.id
  validate_request_body = true
  validate_request_parameters = true
  
}

### Methods
resource "aws_api_gateway_method" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = var.agw.method_http_method
  authorization = "COGNITO_USER_POOLS"
  authorization_scopes = flatten(module.cognito[var.agw.cognito_pool_name].resource_servers_scope_identifiers) 
  authorizer_id = aws_api_gateway_authorizer.cognito.id

  request_validator_id = aws_api_gateway_request_validator.this.id

  request_parameters = {
    "method.request.querystring.city" = true
    "method.request.querystring.lang" = true
  }
}

### Integration
resource "aws_api_gateway_integration" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  integration_http_method = aws_api_gateway_method.this.http_method
  type = "HTTP"
  uri = var.agw.integration_uri

  request_parameters = {
    "integration.request.querystring.city" = "method.request.querystring.city"
    "integration.request.querystring.lang" = "method.request.querystring.lang"
  }
  request_templates = {
      "application/json" = <<EOF
        {
            ""querystring": "$input.params().querystring"
        }
        EOF
  }
}

resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"
  
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

resource "aws_api_gateway_method_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name = var.agw.stage_name
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.this.id, 
      aws_api_gateway_method.this.id,
      aws_api_gateway_resource.this.id
    ]))
  }
}

resource "aws_api_gateway_stage" "this" {
  stage_name = var.agw.stage_name
  rest_api_id = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
}
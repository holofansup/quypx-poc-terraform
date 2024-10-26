### TAGS
variable "common_tags" {
  type        = map(string)
  default     = null
  description = "Default tags for all resources"
}

### LAMBDA
variable "lambda_function" {
  type        = any
  default     = null
  description = "Map variable to define all value for lambda function"
}

variable "lambda_layer" {
  type        = any
  default     = null
  description = "Map varibale for lambda layers"
}

### RDS
variable "aurora" {
  type        = any
  default     = null
  description = "Map variable for rds instance"
}

### COGNITO
variable "cognito_pools" {
  description = "List of Cognito user pool configurations"
  type = list(object({
    user_pool_name                       = string
    alias_attributes                     = list(string)
    auto_verified_attributes             = list(string)
    username_case_sensitive              = bool
    password_minimum_length              = number
    password_require_lowercase           = bool
    password_require_numbers             = bool
    password_require_symbols             = bool
    password_require_uppercase           = bool
    temporary_password_validity_days     = number
    mfa_configuration                    = string
    software_token_mfa_configuration_enabled = bool
    recovery_mechanisms                  = list(object({
      name     = string
      priority = number
    }))
    allow_admin_create_user_only         = bool
    admin_create_user_email_message      = string
    admin_create_user_email_subject      = string
    admin_create_user_sms_message        = string
    email_sending_account                = string
    verification_default_email_option    = string
    verification_email_message           = string
    verification_email_subject           = string
    device_configuration                 = map(any)
    client_name                          = string
    client_generate_secret               = bool
    client_explicit_auth_flows           = list(string)
    client_auth_session_validity         = number
    client_refresh_token_validity        = number
    client_access_token_validity         = number
    client_id_token_validity             = number
    client_prevent_user_existence_errors = string
    client_enable_token_revocation       = bool
  }))
  default = null
}


### ECR
variable "ecr" {
  description = "List of ecr configuration"
  type        = any
  default     = null
}

### APP RUNNER
variable "app_runner" {
  description = "List of app runner instance configuration"
  type = any
  default = null
}
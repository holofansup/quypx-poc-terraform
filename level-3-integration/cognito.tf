locals {
  cognito_pools = {
    for pool in var.cognito_pools :
    pool.user_pool_name => pool
  }
}

module "cognito" {
  source   = "../common/cognito"
  for_each = local.cognito_pools

  user_pool_name           = each.key
  alias_attributes         = each.value.alias_attributes
  auto_verified_attributes = each.value.auto_verified_attributes
  username_configuration = {
    case_sensitive = each.value.username_case_sensitive
  }

  ### PASSWORD config
  password_policy = {
    minimum_length                   = each.value.password_minimum_length
    require_lowercase                = each.value.password_require_lowercase
    require_numbers                  = each.value.password_require_numbers
    require_symbols                  = each.value.password_require_symbols
    require_uppercase                = each.value.password_require_uppercase
    temporary_password_validity_days = each.value.temporary_password_validity_days
  }

  #### MFA config
  mfa_configuration                        = each.value.mfa_configuration
  software_token_mfa_configuration_enabled = each.value.software_token_mfa_configuration_enabled

  #### User account recovery
  recovery_mechanisms = each.value.recovery_mechanisms

  #### Self Sign up option
  admin_create_user_config = {
    allow_admin_create_user_only = each.value.allow_admin_create_user_only
    email_message                = each.value.admin_create_user_email_message
    email_subject                = each.value.admin_create_user_email_subject
    sms_message                  = each.value.admin_create_user_sms_message
  }

  ### email configuration
  email_configuration = {
    email_sending_account = each.value.email_sending_account
  }

  verification_message_template = {
    default_email_option = each.value.verification_default_email_option
    email_message        = each.value.verification_email_message
    email_subject        = each.value.verification_email_subject
  }

  device_configuration = each.value.device_configuration

  ### Clients
  clients = [
    for client in each.value.clients : {
      name                          = client.client_name
      generate_secret               = client.client_generate_secret
      explicit_auth_flows           = client.client_explicit_auth_flows
      auth_session_validity         = client.client_auth_session_validity
      client_refresh_token_validity = client.client_refresh_token_validity
      access_token_validity         = client.client_access_token_validity
      client_id_token_validity      = client.client_id_token_validity
      prevent_user_existence_errors = client.client_prevent_user_existence_errors
      enable_token_revocation       = client.client_enable_token_revocation
    }
  ]

  #### Resource server
  resource_servers = [
    for resource in each.value.resource_servers : {
      name = resource.resource_name
      identifier = resource.resource_identifier
      scope = [
        for scope in resource.resource_scope : {
          scope_name = scope.scope_name
          scope_description = scope.scope_description
        }
      ]
    }
  ]
}

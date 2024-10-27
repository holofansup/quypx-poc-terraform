cognito_pools = [
  {
    user_pool_name           = "poc_dev-cogusrpool-idp-lp-summit"
    alias_attributes         = ["preferred_username"]
    auto_verified_attributes = ["email"]
    username_case_sensitive  = false

    password_minimum_length          = 8
    password_require_lowercase       = false
    password_require_numbers         = false
    password_require_symbols         = false
    password_require_uppercase       = false
    temporary_password_validity_days = 7

    mfa_configuration                        = "OPTIONAL"
    software_token_mfa_configuration_enabled = true

    recovery_mechanisms = [
      {
        name     = "verified_email"
        priority = 1
      }
    ]

    allow_admin_create_user_only    = true
    admin_create_user_email_message = "Dear {username}, your verification code is {####}."
    admin_create_user_email_subject = "Here, your verification code baby"
    admin_create_user_sms_message   = "Your username is {username} and temporary password is {####}."

    email_sending_account = "COGNITO_DEFAULT"

    verification_default_email_option = "CONFIRM_WITH_LINK"
    verification_email_message        = "Your verification code is {####}"
    verification_email_subject        = "Verification code"

    device_configuration = {}

    client_name            = "poc_dev-cogusrpool-idp-lp-summit-client"
    client_generate_secret = false
    client_explicit_auth_flows = [
      "ALLOW_ADMIN_USER_PASSWORD_AUTH",
      "ALLOW_CUSTOM_AUTH",
      "ALLOW_REFRESH_TOKEN_AUTH",
      "ALLOW_USER_PASSWORD_AUTH",
      "ALLOW_USER_SRP_AUTH"
    ]
    client_auth_session_validity         = 3
    client_refresh_token_validity        = 30
    client_access_token_validity         = 24
    client_id_token_validity             = 24
    client_prevent_user_existence_errors = "ENABLED"
    client_enable_token_revocation       = true
  }
]
locals {
  domain = "myexamplepool"
}

resource "aws_cognito_user_pool" "pool" {
  name                     = "TfPool"
  auto_verified_attributes = ["email"]
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_subject_by_link = "Your verification link"
    email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##} "
  }
  username_configuration {
    case_sensitive = false
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 7
      max_length = 50
    }
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = local.domain
  user_pool_id = aws_cognito_user_pool.pool.id
}


resource "aws_cognito_user_pool_client" "client" {
  name                 = "TfAppClient"
  user_pool_id         = aws_cognito_user_pool.pool.id
  allowed_oauth_flows  = ["code", "implicit"]
  allowed_oauth_scopes = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  callback_urls        = ["https://www.example.com"]
  explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_identity_pool" "identitypool" {
  identity_pool_name               = "TFIdentityPool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.pool.endpoint
    server_side_token_check = false
  }
}

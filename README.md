# Configure Cognito

## Background

Configuring Congnito is always a pain, as there are different options need to be configured at different place, which I will definitely forget.

So, Just created this Terraform repo which will create a Cognito User Pool.

## Prerequisite

You need to create an user which will be having the `AmazonCognitoPowerUser` Policy. Create a profile with this in your local machine like this:

```bash
$ cat ~/.aws/config
[tf-cognito]
output = json
region = ap-south-1

$ cat ~/.aws/credentials
[tf-cognito]
aws_access_key_id = <YOUR_ACCESS_KEY_ID>
aws_secret_access_key = <YOUR_SECRET_ACCESS_KEY>
```

Now, you will see that we are using this `tf-cognito` profile in our main.tfvars file.

## How did I do that

There is always a [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#case_sensitive) of Terraform you can refer to. Otherwise, cheapest is to create the resource, update manually, run plan and align them so that there is not difference.

## Caveat

At the time of writing this, Terraform did not have the support for the `MFA and verifications` > `How user will recover their account`. So, with this continues to select the `Not Recommended) Phone if available, otherwise email, and do allow a user to reset their password via phone if they are also using it for MFA.` - option, while I want to choose the `Email only`. But, I could not make it work, probably in future its support will be availble.

## How to run that

I still love Makefile in 2020. So.

### Run Terraform init

```bash
$ cd <project_root>
$ make init
cd terraform && terraform init

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Run Terraform plan

```bash
$ make plan
cd terraform && terraform plan -var-file='main.tfvars'
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cognito_identity_pool.identitypool will be created
  + resource "aws_cognito_identity_pool" "identitypool" {
      + allow_unauthenticated_identities = false
      + arn                              = (known after apply)
      + id                               = (known after apply)
      + identity_pool_name               = "TFIdentityPool"

      + cognito_identity_providers {
          + client_id               = (known after apply)
          + provider_name           = (known after apply)
          + server_side_token_check = false
        }
    }

  # aws_cognito_user_pool.pool will be created
  + resource "aws_cognito_user_pool" "pool" {
      + arn                        = (known after apply)
      + auto_verified_attributes   = [
          + "email",
        ]
      + creation_date              = (known after apply)
      + email_verification_message = (known after apply)
      + email_verification_subject = (known after apply)
      + endpoint                   = (known after apply)
      + id                         = (known after apply)
      + last_modified_date         = (known after apply)
      + mfa_configuration          = "OFF"
      + name                       = "TfPool"
      + sms_verification_message   = (known after apply)

      + admin_create_user_config {
          + allow_admin_create_user_only = (known after apply)

          + invite_message_template {
              + email_message = (known after apply)
              + email_subject = (known after apply)
              + sms_message   = (known after apply)
            }
        }

      + lambda_config {
          + create_auth_challenge          = (known after apply)
          + custom_message                 = (known after apply)
          + define_auth_challenge          = (known after apply)
          + post_authentication            = (known after apply)
          + post_confirmation              = (known after apply)
          + pre_authentication             = (known after apply)
          + pre_sign_up                    = (known after apply)
          + pre_token_generation           = (known after apply)
          + user_migration                 = (known after apply)
          + verify_auth_challenge_response = (known after apply)
        }

      + password_policy {
          + minimum_length                   = (known after apply)
          + require_lowercase                = (known after apply)
          + require_numbers                  = (known after apply)
          + require_symbols                  = (known after apply)
          + require_uppercase                = (known after apply)
          + temporary_password_validity_days = (known after apply)
        }

      + schema {
          + attribute_data_type      = "String"
          + developer_only_attribute = false
          + mutable                  = false
          + name                     = "email"
          + required                 = true

          + string_attribute_constraints {
              + max_length = "15"
              + min_length = "7"
            }
        }

      + sms_configuration {
          + external_id    = (known after apply)
          + sns_caller_arn = (known after apply)
        }

      + username_configuration {
          + case_sensitive = false
        }

      + verification_message_template {
          + default_email_option  = "CONFIRM_WITH_LINK"
          + email_message         = (known after apply)
          + email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##} "
          + email_subject         = (known after apply)
          + email_subject_by_link = "Your verification link"
          + sms_message           = (known after apply)
        }
    }

  # aws_cognito_user_pool_client.client will be created
  + resource "aws_cognito_user_pool_client" "client" {
      + allowed_oauth_flows                  = [
          + "code",
          + "implicit",
        ]
      + allowed_oauth_flows_user_pool_client = true
      + allowed_oauth_scopes                 = [
          + "aws.cognito.signin.user.admin",
          + "email",
          + "openid",
          + "phone",
          + "profile",
        ]
      + callback_urls                        = [
          + "https://www.example.com",
        ]
      + client_secret                        = (sensitive value)
      + explicit_auth_flows                  = [
          + "ALLOW_ADMIN_USER_PASSWORD_AUTH",
          + "ALLOW_REFRESH_TOKEN_AUTH",
          + "ALLOW_USER_SRP_AUTH",
        ]
      + id                                   = (known after apply)
      + name                                 = "TfAppClient"
      + prevent_user_existence_errors        = "ENABLED"
      + refresh_token_validity               = 30
      + supported_identity_providers         = [
          + "COGNITO",
        ]
      + user_pool_id                         = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### Run Terraform apply

```bash
$ make apply
cd  terraform && terraform apply -var-file='main.tfvars'

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cognito_identity_pool.identitypool will be created
  + resource "aws_cognito_identity_pool" "identitypool" {
      + allow_unauthenticated_identities = false
      + arn                              = (known after apply)
      + id                               = (known after apply)
      + identity_pool_name               = "TFIdentityPool"

      + cognito_identity_providers {
          + client_id               = (known after apply)
          + provider_name           = (known after apply)
          + server_side_token_check = false
        }
    }

  # aws_cognito_user_pool.pool will be created
  + resource "aws_cognito_user_pool" "pool" {
      + arn                        = (known after apply)
      + auto_verified_attributes   = [
          + "email",
        ]
      + creation_date              = (known after apply)
      + email_verification_message = (known after apply)
      + email_verification_subject = (known after apply)
      + endpoint                   = (known after apply)
      + id                         = (known after apply)
      + last_modified_date         = (known after apply)
      + mfa_configuration          = "OFF"
      + name                       = "TfPool"
      + sms_verification_message   = (known after apply)

      + admin_create_user_config {
          + allow_admin_create_user_only = (known after apply)

          + invite_message_template {
              + email_message = (known after apply)
              + email_subject = (known after apply)
              + sms_message   = (known after apply)
            }
        }

      + lambda_config {
          + create_auth_challenge          = (known after apply)
          + custom_message                 = (known after apply)
          + define_auth_challenge          = (known after apply)
          + post_authentication            = (known after apply)
          + post_confirmation              = (known after apply)
          + pre_authentication             = (known after apply)
          + pre_sign_up                    = (known after apply)
          + pre_token_generation           = (known after apply)
          + user_migration                 = (known after apply)
          + verify_auth_challenge_response = (known after apply)
        }

      + password_policy {
          + minimum_length                   = (known after apply)
          + require_lowercase                = (known after apply)
          + require_numbers                  = (known after apply)
          + require_symbols                  = (known after apply)
          + require_uppercase                = (known after apply)
          + temporary_password_validity_days = (known after apply)
        }

      + schema {
          + attribute_data_type      = "String"
          + developer_only_attribute = false
          + mutable                  = false
          + name                     = "email"
          + required                 = true

          + string_attribute_constraints {
              + max_length = "15"
              + min_length = "7"
            }
        }

      + sms_configuration {
          + external_id    = (known after apply)
          + sns_caller_arn = (known after apply)
        }

      + username_configuration {
          + case_sensitive = false
        }

      + verification_message_template {
          + default_email_option  = "CONFIRM_WITH_LINK"
          + email_message         = (known after apply)
          + email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##} "
          + email_subject         = (known after apply)
          + email_subject_by_link = "Your verification link"
          + sms_message           = (known after apply)
        }
    }

  # aws_cognito_user_pool_client.client will be created
  + resource "aws_cognito_user_pool_client" "client" {
      + allowed_oauth_flows                  = [
          + "code",
          + "implicit",
        ]
      + allowed_oauth_flows_user_pool_client = true
      + allowed_oauth_scopes                 = [
          + "aws.cognito.signin.user.admin",
          + "email",
          + "openid",
          + "phone",
          + "profile",
        ]
      + callback_urls                        = [
          + "https://www.example.com",
        ]
      + client_secret                        = (sensitive value)
      + explicit_auth_flows                  = [
          + "ALLOW_ADMIN_USER_PASSWORD_AUTH",
          + "ALLOW_REFRESH_TOKEN_AUTH",
          + "ALLOW_USER_SRP_AUTH",
        ]
      + id                                   = (known after apply)
      + name                                 = "TfAppClient"
      + prevent_user_existence_errors        = "ENABLED"
      + refresh_token_validity               = 30
      + supported_identity_providers         = [
          + "COGNITO",
        ]
      + user_pool_id                         = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_cognito_user_pool.pool: Creating...
aws_cognito_user_pool.pool: Creation complete after 1s [id=ap-south-1_yyA44FtuH]
aws_cognito_user_pool_client.client: Creating...
aws_cognito_user_pool_client.client: Creation complete after 1s [id=768j94v8j4rb41nmmmi18m1s76]
aws_cognito_identity_pool.identitypool: Creating...
aws_cognito_identity_pool.identitypool: Creation complete after 1s [id=ap-south-1:11290d13-1c4d-403b-879f-de70b551a633]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

### Run Terraform destroy

```bash
$ make destroy
cd terraform && terraform destroy -var-file='main.tfvars'
aws_cognito_user_pool.pool: Refreshing state... [id=ap-south-1_yyA44FtuH]
aws_cognito_user_pool_client.client: Refreshing state... [id=768j94v8j4rb41nmmmi18m1s76]
aws_cognito_identity_pool.identitypool: Refreshing state... [id=ap-south-1:11290d13-1c4d-403b-879f-de70b551a633]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_cognito_identity_pool.identitypool will be destroyed
  - resource "aws_cognito_identity_pool" "identitypool" {
      - allow_unauthenticated_identities = false -> null
      - arn                              = "arn:aws:cognito-identity:ap-south-1:480288054387:identitypool/ap-south-1:11290d13-1c4d-403b-879f-de70b551a633" -> null
      - id                               = "ap-south-1:11290d13-1c4d-403b-879f-de70b551a633" -> null
      - identity_pool_name               = "TFIdentityPool" -> null
      - openid_connect_provider_arns     = [] -> null
      - saml_provider_arns               = [] -> null
      - supported_login_providers        = {} -> null
      - tags                             = {} -> null

      - cognito_identity_providers {
          - client_id               = "768j94v8j4rb41nmmmi18m1s76" -> null
          - provider_name           = "cognito-idp.ap-south-1.amazonaws.com/ap-south-1_yyA44FtuH" -> null
          - server_side_token_check = false -> null
        }
    }

  # aws_cognito_user_pool.pool will be destroyed
  - resource "aws_cognito_user_pool" "pool" {
      - arn                      = "arn:aws:cognito-idp:ap-south-1:480288054387:userpool/ap-south-1_yyA44FtuH" -> null
      - auto_verified_attributes = [
          - "email",
        ] -> null
      - creation_date            = "2020-09-15T18:42:02Z" -> null
      - endpoint                 = "cognito-idp.ap-south-1.amazonaws.com/ap-south-1_yyA44FtuH" -> null
      - id                       = "ap-south-1_yyA44FtuH" -> null
      - last_modified_date       = "2020-09-15T18:42:02Z" -> null
      - mfa_configuration        = "OFF" -> null
      - name                     = "TfPool" -> null
      - tags                     = {} -> null

      - admin_create_user_config {
          - allow_admin_create_user_only = false -> null
        }

      - email_configuration {
          - email_sending_account = "COGNITO_DEFAULT" -> null
        }

      - password_policy {
          - minimum_length                   = 8 -> null
          - require_lowercase                = true -> null
          - require_numbers                  = true -> null
          - require_symbols                  = true -> null
          - require_uppercase                = true -> null
          - temporary_password_validity_days = 7 -> null
        }

      - schema {
          - attribute_data_type      = "String" -> null
          - developer_only_attribute = false -> null
          - mutable                  = false -> null
          - name                     = "email" -> null
          - required                 = true -> null

          - string_attribute_constraints {
              - max_length = "15" -> null
              - min_length = "7" -> null
            }
        }

      - username_configuration {
          - case_sensitive = false -> null
        }

      - verification_message_template {
          - default_email_option  = "CONFIRM_WITH_LINK" -> null
          - email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##} " -> null
          - email_subject_by_link = "Your verification link" -> null
        }
    }

  # aws_cognito_user_pool_client.client will be destroyed
  - resource "aws_cognito_user_pool_client" "client" {
      - allowed_oauth_flows                  = [
          - "code",
          - "implicit",
        ] -> null
      - allowed_oauth_flows_user_pool_client = true -> null
      - allowed_oauth_scopes                 = [
          - "aws.cognito.signin.user.admin",
          - "email",
          - "openid",
          - "phone",
          - "profile",
        ] -> null
      - callback_urls                        = [
          - "https://www.example.com",
        ] -> null
      - explicit_auth_flows                  = [
          - "ALLOW_ADMIN_USER_PASSWORD_AUTH",
          - "ALLOW_REFRESH_TOKEN_AUTH",
          - "ALLOW_USER_SRP_AUTH",
        ] -> null
      - id                                   = "768j94v8j4rb41nmmmi18m1s76" -> null
      - logout_urls                          = [] -> null
      - name                                 = "TfAppClient" -> null
      - prevent_user_existence_errors        = "ENABLED" -> null
      - read_attributes                      = [] -> null
      - refresh_token_validity               = 30 -> null
      - supported_identity_providers         = [
          - "COGNITO",
        ] -> null
      - user_pool_id                         = "ap-south-1_yyA44FtuH" -> null
      - write_attributes                     = [] -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_cognito_identity_pool.identitypool: Destroying... [id=ap-south-1:11290d13-1c4d-403b-879f-de70b551a633]
aws_cognito_identity_pool.identitypool: Destruction complete after 1s
aws_cognito_user_pool_client.client: Destroying... [id=768j94v8j4rb41nmmmi18m1s76]
aws_cognito_user_pool_client.client: Destruction complete after 0s
aws_cognito_user_pool.pool: Destroying... [id=ap-south-1_yyA44FtuH]
aws_cognito_user_pool.pool: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.
```

That's it!

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
  aws_service_access_principals = [
    "sso.amazonaws.com",
  ]
}

data "aws_ssoadmin_instances" "this" {}

locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_identitystore_user" "jacob" {
  identity_store_id = local.identity_store_id

  display_name = "Jacob"
  user_name    = "jacob"

  name {
    given_name  = "Jacob"
    family_name = "Yablonski"
  }

  emails {
    value   = "jyablonski9@gmail.com"
    primary = true
  }
}

resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdministratorAccess"
  instance_arn     = local.instance_arn
  session_duration = "PT12H" # max for the assumed role into the account
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

resource "aws_ssoadmin_account_assignment" "jacob_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_user.jacob.user_id
  principal_type = "USER"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

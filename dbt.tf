module "dbt_s3_ci_module" {
  source                   = "./modules/s3"
  bucket_name              = "nba-elt-dbt-ci"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 365
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
    "${module.dbt_github_cicd.iam_role_arn}",
    "${module.kimball_github_cicd.iam_role_arn}"
  ]
}

locals {
  trunk_based_test_bucket = "jyablonski-trunk-test"
  trunk_role_name         = "trunk-based-example"
  trunk_repo_name         = "jyablonski/jyablonski_trunk_based_example"
}

module "trunk_test_stg" {
  source                   = "./modules/s3"
  bucket_name              = "${local.trunk_based_test_bucket}-stg"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 14
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}


module "trunk_test_prod" {
  source                   = "./modules/s3"
  bucket_name              = "${local.trunk_based_test_bucket}-prod"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 14
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

module "trunk_test_github_cicd" {
  source              = "./modules/iam_github"
  iam_role_name       = local.trunk_role_name
  github_provider_arn = aws_iam_openid_connect_provider.github_provider.arn
  github_repo         = local.trunk_repo_name
  iam_role_policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${module.trunk_test_stg.s3_bucket_arn}",
                "${module.trunk_test_stg.s3_bucket_arn}/*",
                "${module.trunk_test_prod.s3_bucket_arn}/",
                "${module.trunk_test_prod.s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF

}

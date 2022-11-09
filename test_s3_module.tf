module "s3_test_module" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski-test-bucket1"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 14
  account_id               = data.aws_caller_identity.current.account_id
}
module "dvc_s3_module" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski-dvc-praq"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 180
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}
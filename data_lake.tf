module "iceberg_lake" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski-iceberg"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 14
  account_id               = data.aws_caller_identity.current.account_id
}

module "delta_lake" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski-delta"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 365
  account_id               = data.aws_caller_identity.current.account_id
}
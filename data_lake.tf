module "iceberg_lake" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski2-iceberg"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 14
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

module "delta_lake" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski2-delta"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 365
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}
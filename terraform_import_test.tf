locals {
  import_bucket = "jyablonski-tf-bucket-97"
}
resource "aws_s3_bucket" "terraform_import_bucket" {
  bucket        = local.import_bucket
  force_destroy = false
}

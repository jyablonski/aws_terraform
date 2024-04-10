locals {
  import_bucket = "jyablonski-tf-bucket-97"
}

# https://spacelift.io/blog/importing-exisiting-infrastructure-into-terraform
# first create a mock example of the resource with bare minimum attributes set
# then run the import command
# terraform import aws_s3_bucket.terraform_import_bucket jyablonski-tf-bucket-97

# >>> The resources that were imported are shown above. These resources are now in
# >>> your Terraform state and will henceforth be managed by Terraform.

# afterwards run terrafrom apply and continue modifying the attributes til you get it 
# in a place where the terraform is setup correctly
# otherwise it could force dstroy the resource which goes against the whole point of why
# we're importing this resource in the first place
resource "aws_s3_bucket" "terraform_import_bucket" {
  bucket        = local.import_bucket
  force_destroy = false
}

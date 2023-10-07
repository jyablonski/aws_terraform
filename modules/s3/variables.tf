variable "bucket_name" {
  type = string
}

variable "prefix_expiration_length" {
  type    = number
  default = 7
}

variable "prefix_expiration_name" {
  type    = string
  default = "*"
}

variable "s3_access_resources" {
  type = list(string)
}

variable "bucket_acl" {
  type    = string
  default = "private"
}

variable "is_versioning_enabled" {
  type    = string
  default = "Disabled"
}

variable "object_ownership" {
  type    = string
  default = "BucketOwnerPreferred"
}
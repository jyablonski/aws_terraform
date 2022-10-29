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

variable "account_id" {
  type = any
}

variable "bucket_acl" {
  type    = string
  default = "private"
}

variable "is_versioning_enabled" {
  type    = string
  default = "Disabled"
}

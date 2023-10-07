variable "storage_integration_name" {
  type = string
}

variable "storage_integration_comment" {
  type = string
  default = ""
}

variable "storage_integration_type" {
  type    = string
  default = "EXTERNAL_STAGE"
}

variable "storage_allowed_locations" {
  type = string
}

variable "storage_blocked_locations" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "iam_role_name" {
  type = string
}

variable "snowflake_integration_user_roles" {
  type = list(string)
}

variable "file_suffix" {
  type    = string
  default = ".csv"
}

variable "aws_account_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}
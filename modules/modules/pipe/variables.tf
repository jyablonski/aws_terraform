variable "pipe_db" {
  type = string
}

variable "pipe_schema" {
  type = string
}

variable "pipe_name" {
  type = string
}

variable "pipe_comment" {
  type = string
}

variable "pipe_copy_statement" {
  type = string
}

variable "is_auto_ingest" {
  type    = bool
  default = true
}

variable "file_suffix" {
  type    = string
  default = ".csv"
}

variable "storage_integration" {
  type = string
}

variable "error_integration" {
  type = string
}

variable "roles" {
  type    = list(any)
  default = ["ACCOUNTADMIN"]
}

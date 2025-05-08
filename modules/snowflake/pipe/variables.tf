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

variable "pipe_destination_table" {
  type = string
}

variable "pipe_stage" {
  type = string
}

variable "is_auto_ingest" {
  type    = bool
  default = true
}

variable "file_format" {
  type = string
}

# variable "storage_integration" {
#   type = string
# }

# variable "error_integration" {
#   type = string
#   default = null
# }

variable "usage_roles" {
  type    = list(any)
  default = ["ACCOUNTADMIN"]
}

variable "copy_options" {
  type    = string
  default = "" # Default to empty if no additional copy options are provided
}
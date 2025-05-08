variable "name" {
  type        = string
  description = "The name of the file format."
}

variable "database" {
  type        = string
  description = "The Snowflake database name."
}

variable "schema" {
  type        = string
  description = "The schema name."
}

variable "format_type" {
  type        = string
  description = "The file format type (e.g., 'PARQUET', 'CSV')."
}

variable "file_format_usage_roles" {
  type        = list(string)
  description = "List of database role names to grant USAGE on this file format."
}

# Optional format parameters
variable "compression" {
  type    = string
  default = null
}

variable "record_delimiter" {
  type    = string
  default = null
}

variable "field_delimiter" {
  type    = string
  default = null
}

variable "file_extension" {
  type    = string
  default = null
}

variable "skip_header" {
  type    = number
  default = null
}

variable "binary_as_text" {
  type    = bool
  default = null
}

variable "trim_space" {
  type    = bool
  default = null
}

variable "null_if" {
  type    = list(string)
  default = null
}

variable "empty_field_as_null" {
  type    = bool
  default = null
}

variable "enable_octal" {
  type    = bool
  default = null
}

variable "escape_unenclosed_field" {
  type    = string
  default = null
}

variable "encoding" {
  type    = string
  default = null
}

variable "date_format" {
  type    = string
  default = null
}

variable "time_format" {
  type    = string
  default = null
}

variable "timestamp_format" {
  type    = string
  default = null
}

variable "binary_format" {
  type    = string
  default = null
}
